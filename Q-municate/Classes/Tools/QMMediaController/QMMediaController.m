//
//  QMMediaController.m
//  Q-municate
//
//  Created by Vitaliy Gurkovsky on 2/19/17.
//  Copyright © 2017 Quickblox. All rights reserved.
//

#import "QMMediaController.h"
#import "QMMediaViewDelegate.h"
#import "QMChatAttachmentCell.h"
#import "QMCore.h"
#import "QMAudioPlayer.h"
#import "QMPhoto.h"
#import "NYTPhotosViewController.h"
#import "QMDateUtils.h"
#import "QMImageLoader+QBChatAttachment.h"
#import "UIImage+QM.h"

@interface QMMediaController() <QMAudioPlayerDelegate,
NYTPhotosViewControllerDelegate,
QMMediaHandler,
QMAttachmentContentServiceDelegate>

@property (weak, nonatomic) UIViewController <QMMediaControllerDelegate> *viewController;
@property (strong, nonatomic) QMChatAttachmentService *attachmentsService;
@property (strong, nonatomic) AVPlayer *videoPlayer;
@property (weak, nonatomic) UIView *photoReferenceView;
@property (weak, nonatomic) __kindof UIViewController *presentedViewController;
@end

@implementation QMMediaController

@dynamic attachmentsService;

//MARK: - NSObject

- (instancetype)initWithViewController:(UIViewController <QMMediaControllerDelegate> *)viewController {
    
    if (self = [super init]) {
        
        _viewController = viewController;
        [QMAudioPlayer audioPlayer].playerDelegate = self;
        self.attachmentsService.contentService.delegate = self;
        
    }
    
    return self;
}

- (void)dealloc {
    
    [QMAudioPlayer audioPlayer].playerDelegate = nil;
    
    [[QMImageLoader instance] cancelAll];
    [self.attachmentsService.assetService cancelAllOperations];
    [self.attachmentsService.contentService cancelDownloadOperations];
    [self.attachmentsService removeDelegate:self];
}

//MARK: - Interface

- (void)configureView:(id<QMMediaViewDelegate>)view
          withMessage:(QBChatMessage *)message {
    
    QBChatAttachment *attachment = [message.attachments firstObject];
    NSParameterAssert(attachment != nil);
    
    if (!view.mediaHandler) {
        view.mediaHandler = self;
    }
    if (attachment.attachmentType != QMAttachmentContentTypeAudio && attachment.ID) {
        
        if (view.messageID != nil && ![view.messageID isEqualToString:message.ID]) {
            
            QBChatMessage *messageToCancel = [[QMCore instance].chatService.messagesMemoryStorage messageWithID:view.messageID
                                                                                                   fromDialogID:self.viewController.dialogID];
            [self cancelOperationsForMessage:messageToCancel];
        }
    }
    
    [self updateView:view
      withAttachment:attachment
             message:message];
}


- (void)updateView:(id<QMMediaViewDelegate>)view
    withAttachment:(QBChatAttachment *)attachment
           message:(QBChatMessage *)message {
    
    view.messageID = message.ID;
    view.duration = attachment.duration;
    view.playable = attachment.attachmentType == QMAttachmentContentTypeAudio ||  attachment.attachmentType == QMAttachmentContentTypeVideo;
    view.cancellable = attachment.attachmentType == QMAttachmentContentTypeAudio || attachment.ID == nil;
    
    QMMessageAttachmentStatus attachmentStatus = [self.attachmentsService attachmentStatusForMessage:message];
    
    QMLog(@"attStatus = %d messageID:%@", attachmentStatus, message.ID);
    
    if (attachmentStatus == QMMessageAttachmentStatusNotLoaded) {
        view.viewState = QMMediaViewStateNotReady;
    }
    else if (attachmentStatus == QMMessageAttachmentStatusLoading
             || attachmentStatus == QMMessageAttachmentStatusUploading) {
        view.viewState = QMMediaViewStateLoading;
        view.progress = [self.attachmentsService.contentService progressForMessageWithID:message.ID];
    }
    else if (attachmentStatus == QMMessageAttachmentStatusPreparing) {
        view.viewState = QMMediaViewStateLoading;
    }
    else if (attachmentStatus == QMMessageAttachmentStatusLoaded) {
    
        if (attachment.attachmentType == QMAttachmentContentTypeAudio) {
            
            QMAudioPlayerStatus *status = [QMAudioPlayer audioPlayer].status;
            
            if ([status.mediaID isEqualToString:message.ID] && status.playerState != QMAudioPlayerStateStopped) {
                
                [self updateView:view withPlayerStatus:status];
            }
            else {
                view.viewState = QMMediaViewStateReady;
            }
        }
    }
    else if (attachmentStatus == QMMessageAttachmentStatusError) {
        view.viewState = QMMediaViewStateError;
        return;
    }
    
    if (attachment.attachmentType != QMAttachmentContentTypeAudio) {
        [self loadAttachment:attachment
                  forMessage:message
                    withView:view];
    }
}

- (void)loadAttachment:(QBChatAttachment *)attachment
            forMessage:(QBChatMessage *)message
              withView:(id<QMMediaViewDelegate>)view {
    
    if (attachment.attachmentType == QMAttachmentContentTypeImage) {
        
        CGSize targetSize  = ((QMBaseMediaCell*)view).previewImageView.bounds.size;
        QMImageTransform *transform = [QMImageTransform transformWithSize:targetSize
                                                     customTransformBlock:^UIImage * _Nullable(NSURL * _Nonnull __unused imageURL, UIImage * _Nonnull originalImage) {
                                                         return [originalImage imageWithCornerRadius:4 targetSize:targetSize];
                                                     }];
        
        
        NSURL *url = [attachment remoteURLWithToken:NO];
        
        if (!url) {
            
            if (attachment.image) {
                
                [transform applyTransformForImage:attachment.image
                                  completionBlock:^(UIImage * _Nonnull transformedImage) {
                                      [QMImageLoader.instance.imageCache storeImage:attachment.image
                                                                             forKey:message.ID
                                                                         completion:nil];
                                      view.image = transformedImage;
                                  }];
            }
            
            view.viewState = QMMediaViewStateLoading;
        }
        else {
            
            UIImage *cachedImage = [QMImageLoader.instance.imageCache imageFromCacheForKey:[transform keyWithURL:url]];
            UIImage *tempImage = [QMImageLoader.instance.imageCache imageFromCacheForKey:message.ID];
            if (cachedImage) {
                
                view.viewState = QMMediaViewStateReady;
                view.image = cachedImage;
            }
            else if (tempImage) {
                
                view.viewState = QMMediaViewStateReady;
                [transform applyTransformForImage:tempImage
                                  completionBlock:^(UIImage * _Nonnull transformedImage) {
                                      [QMImageLoader.instance.imageCache storeImage:tempImage
                                                                             forKey:url.absoluteString
                                                                         completion:nil];
                                      view.image = transformedImage;
                                  }];
            }
            else {
                view.viewState = QMMediaViewStateLoading;
                
                [[QMImageLoader instance] downloadImageWithURL:url
                                                         token:[QBSession currentSession].sessionDetails.token
                                                     transform:transform
                                                       options:SDWebImageHighPriority | SDWebImageContinueInBackground | SDWebImageAllowInvalidSSLCertificates
                                                      progress:^(NSInteger receivedSize,
                                                                 NSInteger expectedSize,
                                                                 NSURL * _Nullable __unused targetURL)
                 {
                     if ([view.messageID isEqualToString:message.ID]) {
                         CGFloat progress = receivedSize/(float)expectedSize;
                         dispatch_async(dispatch_get_main_queue(), ^{
                             view.progress = progress;
                         });
                     }
                 } completed:^(UIImage * _Nullable __unused image,
                               UIImage * _Nullable transfomedImage,
                               NSError * _Nullable error,
                               SDImageCacheType __unused cacheType,
                               BOOL __unused finished,
                               NSURL * _Nonnull __unused imageURL) {
                     
                     if ([view.messageID isEqualToString:message.ID]) {
                         if (transfomedImage) {
                             QMLog(@"_IMAGE has transform messageID:%@",message.ID);
                             view.viewState = QMMediaViewStateReady;
                             view.image = transfomedImage;
                         }
                         else {
                             QMLog(@"_IMAGE hasn't transform messageID:%@",message.ID);
                         }
                         
                         if (error) {
                             QMLog(@"_IMAGE error %@ messageID:%@",error, message.ID);
                             [view showLoadingError:error];
                         }
                     }
                     
                 }];
            }
        }
    }
    else if (attachment.attachmentType == QMAttachmentContentTypeVideo) {
        
        UIImage *image = attachment.image;
        
        if (image) {
            view.image = image;
            view.viewState = QMMediaViewStateReady;
            [QMImageLoader.instance.imageCache storeImage:image forKey:message.ID completion:nil];
        }
        else {
            image = [QMImageLoader.instance.imageCache imageFromCacheForKey:message.ID];
            
            if (image) {
                view.image = image;
                view.viewState = QMMediaViewStateReady;
            }
            else {
                
                view.viewState = QMMediaViewStateLoading;
                [self.attachmentsService prepareAttachment:attachment
                                                   message:message
                                                completion:^(UIImage * _Nullable thumbnailImage,
                                                             Float64 durationSeconds,
                                                             CGSize size,
                                                             NSError * _Nullable error,
                                                             BOOL cancelled)
                 {
                     if (cancelled) {
                         return;
                     }
                     else if (error) {
                         view.viewState = QMMediaViewStateError;
                     }
                     else {
                         attachment.image = image;
                         attachment.duration = lround(durationSeconds);
                         attachment.width =  lround(size.width);
                         attachment.height =  lround(size.height);
                         
                         message.attachments = @[attachment];
                         [QMCore.instance.chatService.messagesMemoryStorage updateMessage:message];
                         
                         if ([view.messageID isEqualToString:message.ID]) {
                             if (thumbnailImage) {
                                 view.image = thumbnailImage;
                                 [QMImageLoader.instance.imageCache storeImage:thumbnailImage forKey:message.ID completion:nil];
                             }
                             if (durationSeconds > 0) {
                                 view.duration = lround(durationSeconds);
                             }
                             view.viewState = QMMediaViewStateReady;
                         }
                     }
                 }];
            }
        }
    }
    if (attachment.attachmentType == QMAttachmentContentTypeAudio) {
        
        __weak typeof(self) weakSelf = self;
        [self.attachmentsService attachmentWithID:attachment.ID message:message progressBlock:^(float progress) {
            if ([view.messageID isEqualToString:message.ID]) {
                view.progress = progress;
            }
        } completion:^(QMAttachmentOperation * _Nonnull op) {
            if (op.isCancelled) {
                return;
            }
            if (![view.messageID isEqualToString:message.ID]) {
                return;
            }
            
            if (!op.error) {
                
                view.duration = attachment.duration;
                
                if ([QMAudioPlayer audioPlayer].status.playerState != QMAudioPlayerStatePlaying) {
                    [weakSelf playAttachment:attachment forMessage:message];
                }
                else {
                    view.viewState = QMMediaViewStateReady;
                }
            }
            else {
                view.viewState = QMMediaViewStateError;
            }
        }];
    }
    if (attachment.attachmentType == QMAttachmentContentTypeAudio || attachment.attachmentType == QMAttachmentContentTypeVideo) {
        
        BOOL isReady = [self.attachmentsService attachmentIsReadyToPlay:attachment message:message];
        if (isReady) {
            view.viewState = QMMediaViewStateReady;
        }
        
        if (isReady) {
            
            if (attachment.attachmentType == QMAttachmentContentTypeAudio) {
                
                QMAudioPlayerStatus *status = [QMAudioPlayer audioPlayer].status;
                
                if ([status.mediaID isEqualToString:message.ID] && status.playerState != QMAudioPlayerStateStopped) {
                    
                    [self updateView:view withPlayerStatus:status];
                }
                else {
                    view.viewState = QMMediaViewStateReady;
                }
            }
        }
        else {
            
            if (attachment.ID == nil) {
                
                view.viewState = QMMediaViewStateLoading;
            }
        }
    }
}

- (void)didTapMediaButton:(id<QMMediaViewDelegate>)view {
    
    NSParameterAssert([view conformsToProtocol:@protocol(QMMediaViewDelegate)]);
    
    NSString *messageID = view.messageID;
    NSParameterAssert(messageID);
    
    QBChatMessage *message = [[QMCore instance].chatService.messagesMemoryStorage messageWithID:messageID
                                                                                   fromDialogID:self.viewController.dialogID];
    
    QBChatAttachment *attachment = [message.attachments firstObject];
    
    NSParameterAssert(attachment);
    
    QMMessageAttachmentStatus attachmentStatus = [self.attachmentsService attachmentStatusForMessage:message];
    
    if (attachmentStatus == QMMessageAttachmentStatusNotLoaded) {
        if (!attachment.ID) {
            [QMCore.instance.chatService deleteMessageLocally:message];
            return;
        }
    }
    else if (attachmentStatus == QMMessageAttachmentStatusUploading) {
        [self.attachmentsService cancelOperationsWithMessageID:messageID];
        [QMCore.instance.chatService deleteMessageLocally:message];
        return;
    }
    else if (attachmentStatus == QMMessageAttachmentStatusError) {
        if (!attachment.ID) {
            [QMCore.instance.chatService.deferredQueueManager perfromDefferedActionForMessage:message withCompletion:nil];
            return;
        }
        else {
            [self loadAttachment:attachment
                      forMessage:message
                        withView:view];
            return;
        }
    }
    
    [self didTapContainer:view];
}

//MARK: - QMChatAttachmentService Delegate

- (void)chatAttachmentService:(QMChatAttachmentService *)__unused chatAttachmentService
     didChangeLoadingProgress:(CGFloat)progress
                   forMessage:(QBChatMessage *)message
                   attachment:(QBChatAttachment *)__unused attachment {
    
    id <QMMediaViewDelegate> view = [self.viewController viewForMessage:message];
    if (view) {
        view.progress = progress;
    }
}

- (void)chatAttachmentService:(QMChatAttachmentService *)__unused chatAttachmentService
   didChangeUploadingProgress:(CGFloat)progress
                   forMessage:(QBChatMessage *)message {
    
    id <QMMediaViewDelegate> view = [self.viewController viewForMessage:message];
    if (view) {
        view.progress = progress;
    }
}

- (void)cancelOperationsForMessage:(QBChatMessage *)message {
    
    QBChatAttachment *attachemnt = [message.attachments firstObject];
    [QMImageLoader.instance cancelOperationWithURL:[attachemnt remoteURLWithToken:NO]];
    
    [self.attachmentsService.assetService cancelOperationWithID:message.ID];
}

- (void)player:(QMAudioPlayer * __unused)player
didUpdateStatus:(QMAudioPlayerStatus *)status {
    
    NSString *mediaID = status.mediaID;
    
    NSParameterAssert(mediaID);
    
    QBChatMessage *message = [[QMCore instance].chatService.messagesMemoryStorage messageWithID:mediaID
                                                                                   fromDialogID:self.viewController.dialogID];
    id <QMMediaViewDelegate> view = [self.viewController viewForMessage:message];
    [self updateView:view withPlayerStatus:status];
}

- (void)updateView:(id <QMMediaViewDelegate>)view
  withPlayerStatus:(QMAudioPlayerStatus *)status {
    
    QMAudioPlayerState playerState = status.playerState;
    
    BOOL isActive = playerState == QMAudioPlayerStatePlaying;
    NSTimeInterval currentTime =
    status.playerState == QMAudioPlayerStateStopped ? 0.0 : status.currentTime;
    
    view.viewState = isActive ? QMMediaViewStateActive : QMMediaViewStateReady;
    
    view.duration = status.duration;
    view.currentTime = currentTime;
    
    if (status.playerState == QMAudioPlayerStateStopped) {
        view.duration = status.duration;
    }
}

//MARK: QMEventHandler

- (void)didTapContainer:(id<QMMediaViewDelegate>)view {
    
    NSParameterAssert([view conformsToProtocol:@protocol(QMMediaViewDelegate)]);
    
    NSString *messageID = view.messageID;
    NSParameterAssert(messageID);
    
    QBChatMessage *message = [[QMCore instance].chatService.messagesMemoryStorage messageWithID:messageID
                                                                                   fromDialogID:self.viewController.dialogID];
    
    QBChatAttachment *attachment = [message.attachments firstObject];
    
    NSParameterAssert(attachment);
    QMMessageAttachmentStatus attachmentStatus = [self.attachmentsService attachmentStatusForMessage:message];
    
    if (attachment.attachmentType == QMAttachmentContentTypeImage) {
        
        QBUUser *user =
        [QMCore.instance.usersService.usersMemoryStorage userWithID:message.senderID];
        
        QMPhoto *photo = [[QMPhoto alloc] init];
        
        if (attachment.ID) {
            photo.image = [QMImageLoader.instance originalImageWithURL:[attachment remoteURLWithToken:NO]];
        }
        else {
            photo.image = attachment.image;
        }
        
        NSString *title = user.fullName ?: [NSString stringWithFormat:@"%tu", user.ID];
        
        UIFont *font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        photo.attributedCaptionTitle =
        [[NSAttributedString alloc] initWithString:title
                                        attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor],
                                                     NSFontAttributeName: font}];
        photo.attributedCaptionSummary =
        [[NSAttributedString alloc] initWithString:[QMDateUtils formatDateForTimeRange:message.dateSent]
                                        attributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor],
                                                     NSFontAttributeName:font }];
        
        self.photoReferenceView = [(QMBaseMediaCell *)view previewImageView];
        
        [self presentViewControllerWithPhoto:photo];
    }
    else if (attachment.attachmentType == QMAttachmentContentTypeVideo) {
        
        if (attachmentStatus == QMMessageAttachmentStatusPreparing || attachmentStatus == QMMessageAttachmentStatusError) {
            return;
        }
        [self playAttachment:attachment forMessage:message];
    }
    else if (attachment.attachmentType == QMAttachmentContentTypeAudio) {
        
        if (attachmentStatus == QMMessageAttachmentStatusLoading) {
            view.viewState = QMMediaViewStateNotReady;
            [self.attachmentsService cancelOperationsWithMessageID:messageID];
        }
        else if (attachmentStatus == QMMessageAttachmentStatusNotLoaded) {
            if (!attachment.ID) {
                return;
            }
            view.viewState = QMMediaViewStateLoading;
            
            __weak typeof(self) weakSelf = self;
            [self.attachmentsService attachmentWithID:attachment.ID
                                              message:message
                                        progressBlock:^(float progress)
             {
                 if ([view.messageID isEqualToString:message.ID]) {
                     view.progress = progress;
                 }
             } completion:^(QMAttachmentOperation * _Nonnull op) {
                 
                 if (op.isCancelled) {
                     return;
                 }
                 if (![view.messageID isEqualToString:message.ID]) {
                     return;
                 }
                 
                 if (!op.error) {
                     
                     view.duration = attachment.duration;
                     
                     if ([QMAudioPlayer audioPlayer].status.playerState != QMAudioPlayerStatePlaying) {
                         [weakSelf playAttachment:attachment forMessage:message];
                     }
                     else {
                         view.viewState = QMMediaViewStateReady;
                     }
                 }
                 else {
                     view.viewState = QMMediaViewStateNotReady;
                 }
             }];
        }
        else if (attachmentStatus == QMMessageAttachmentStatusLoaded) {
            [self playAttachment:attachment forMessage:message];
        }
    }
}

- (void)playAttachment:(QBChatAttachment *)attachment
            forMessage:(QBChatMessage *)message {
    
    if (attachment.attachmentType == QMAttachmentContentTypeAudio) {
        
        NSURL *fileURL = [self.attachmentsService.storeService fileURLForAttachment:attachment
                                                                          messageID:message.ID
                                                                           dialogID:message.dialogID];
        
        [[QMAudioPlayer audioPlayer] playMediaAtURL:fileURL withID:message.ID];
    }
    
    if (attachment.attachmentType == QMAttachmentContentTypeVideo) {
        
        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:attachment.remoteURL];
        
        
        if (self.videoPlayer != nil) {
            
            [self.videoPlayer replaceCurrentItemWithPlayerItem:nil];
            [self.videoPlayer replaceCurrentItemWithPlayerItem:playerItem];
        }
        else {
            self.videoPlayer = [[AVPlayer alloc] initWithPlayerItem:playerItem];
        }
        
        AVPlayerViewController *playerVC = [AVPlayerViewController new];
        playerVC.player = self.videoPlayer;
        
        
        __weak typeof(self) weakSelf = self;
        
        [self.viewController presentViewController:playerVC
                                          animated:YES
                                        completion:^{
                                            
                                            [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
                                            [weakSelf.videoPlayer play];
                                        }];
    }
}

- (QMChatAttachmentService *)attachmentsService {
    
    return QMCore.instance.chatService.chatAttachmentService;
}

- (void)chatAttachmentService:(QMChatAttachmentService *)__unused chatAttachmentService
    didChangeAttachmentStatus:(QMMessageAttachmentStatus)__unused status
                   forMessage:(QBChatMessage *)message {
    
    QBChatAttachment *attachment = message.attachments.firstObject;
    
    if ([self.viewController respondsToSelector:@selector(viewForMessage:)]) {
        
        id <QMMediaViewDelegate> view = [self.viewController viewForMessage:message];
        
        if (view) {
            [self updateView:view
              withAttachment:attachment
                     message:message];
        }
    }
}

//MARK:  - NYTPhotosViewController

- (void)didFinishPickingPhoto:(UIImage *)pickedPhoto {
    
    // clearing previous reference view
    self.photoReferenceView = nil;
    
    QMPhoto *photo = [[QMPhoto alloc] init];
    photo.image = pickedPhoto;
    
    UIColor *darkColor = [UIColor colorWithWhite:0.0 alpha:0.6f];
    UIImage *backgroundImage = [UIImage resizableImageWithColor:darkColor
                                                   cornerRadius:10.0];
    
    UIBarButtonItem *rightBarButtonItem =
    [self barButtonWithTitle:NSLocalizedString(@"QM_STR_SEND", nil)
             backgroundImage:backgroundImage action:@selector(notifyAboutAcceptingPickedImage)];
    
    UIBarButtonItem *leftBarButtonItem =
    [self barButtonWithTitle:NSLocalizedString(@"QM_STR_CANCEL", nil)
             backgroundImage:backgroundImage action:@selector(notifyAboutCancellingPickedImage)];
    
    [self presentViewControllerWithPhoto:photo
                      rightBarButtonItem:rightBarButtonItem
                       leftBarButtonItem:leftBarButtonItem];
}

- (UIBarButtonItem *)barButtonWithTitle:(NSString *)title
                        backgroundImage:(UIImage *)backgroundImage
                                 action:(SEL)action {
    
    UIButton *button = [[UIButton alloc] init];
    
    if (title) {
        
        CGSize textSize =
        [title sizeWithAttributes:@{NSFontAttributeName : button.titleLabel.font}];
        
        button.frame = CGRectMake(0, 0, textSize.width + 20, 30);
        
        [button setTitle:title forState:UIControlStateNormal];
    }
    else {
        button.frame = CGRectMake(0, 0, 30, 30);
    }
    
    [button addTarget:self
               action:action
     forControlEvents:UIControlEventTouchDown];
    
    [button setBackgroundImage:backgroundImage
                      forState:UIControlStateNormal];
    
    return [[UIBarButtonItem alloc] initWithCustomView:button];
}


- (void)notifyAboutAcceptingPickedImage {
    
    NYTPhotosViewController *photosViewController = (NYTPhotosViewController *)_presentedViewController;
    [_viewController sendAttachmentMessageWithImage:photosViewController.currentlyDisplayedPhoto.image];
    [_presentedViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)notifyAboutCancellingPickedImage {
    
    [_presentedViewController dismissViewControllerAnimated:YES completion:nil];
}


- (void)presentViewControllerWithPhoto:(QMPhoto *)photo {
    
    [self presentViewControllerWithPhoto:photo
                      rightBarButtonItem:nil
                       leftBarButtonItem:nil];
}

- (void)presentViewControllerWithPhoto:(QMPhoto *)photo
                    rightBarButtonItem:(UIBarButtonItem *)rightBarButtonItem
                     leftBarButtonItem:(UIBarButtonItem *)leftBarButtonItem {
    
    NYTPhotosViewController *photosViewController =
    [[NYTPhotosViewController alloc] initWithPhotos:@[photo]];
    
    if (rightBarButtonItem != nil) {
        photosViewController.rightBarButtonItem = rightBarButtonItem;
    }
    
    if (leftBarButtonItem != nil) {
        photosViewController.leftBarButtonItem = leftBarButtonItem;
    }
    
    photosViewController.delegate = self;
    
    
    [self.viewController.view endEditing:YES]; // hiding keyboard
    [self.viewController presentViewController:photosViewController
                                      animated:YES
                                    completion:nil];
    _presentedViewController = photosViewController;
}

//MARK: - NYTPhotosViewControllerDelegate

- (UIView *)photosViewController:(NYTPhotosViewController *)__unused photosViewController referenceViewForPhoto:(id<NYTPhoto>)__unused photo {
    return self.photoReferenceView;
}


//MARK: - QMAttachmentContentServiceDelegate
- (BOOL)attachmentContentService:(QMAttachmentContentService *)__unused contentService
        shouldDownloadAttachment:(QBChatAttachment *)attachment
                       messageID:(NSString *)__unused messageID {
    
    return attachment.attachmentType == QMAttachmentContentTypeImage ||
    attachment.attachmentType == QMAttachmentContentTypeAudio;
}





@end

