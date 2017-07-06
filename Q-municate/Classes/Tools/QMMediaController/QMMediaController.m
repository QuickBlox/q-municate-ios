//
//  QMMediaController.m
//  Q-municate
//
//  Created by Vitaliy Gurkovsky on 2/19/17.
//  Copyright © 2017 Quickblox. All rights reserved.
//

#import "QMMediaController.h"
#import "QMMediaViewDelegate.h"
#import "QMMediaPresenter.h"
#import "QMChatAttachmentCell.h"
#import "QMCore.h"
#import "QMAudioPlayer.h"
#import "QMMediaInfoService.h"
#import "QMPhoto.h"
#import "NYTPhotosViewController.h"
#import "QMDateUtils.h"
#import "QMMediaPresenter+QBChatAttachment.h"
#import "QMChatModel.h"
#import "QMChatAttachmentModel.h"
#import "QMImageLoader+QBChatAttachment.h"

@interface QMMediaController() <QMAudioPlayerDelegate,
QMPlayerService,
QMMediaAssistant,
QMEventHandler,
NYTPhotosViewControllerDelegate,
QMMediaHandler>

@property (strong, nonatomic) NSMutableDictionary *mediaPresenters;

@property (weak, nonatomic) UIViewController <QMMediaControllerDelegate> *viewController;
@property (strong, nonatomic) QMChatAttachmentService *attachmentsService;
@property (strong, nonatomic) AVPlayer *videoPlayer;
@property (strong, nonatomic) NSMutableDictionary<NSString *, id<QMChatModelProtocol>> *chatModels;

@end

@implementation QMMediaController
@dynamic attachmentsService;

//MARK: - NSObject

- (instancetype)initWithViewController:(UIViewController <QMMediaControllerDelegate> *)viewController {
    
    if (self = [super init]) {
        
        _mediaPresenters = [NSMutableDictionary dictionary];
        _viewController = viewController;
        [QMAudioPlayer audioPlayer].playerDelegate = self;
        _chatModels = [NSMutableDictionary dictionary];
        
    }
    
    return  self;
}

- (void)dealloc {
    
    [QMAudioPlayer audioPlayer].playerDelegate = nil;
    [self.mediaPresenters removeAllObjects];
    [self.attachmentsService.infoService cancellAllOperations];
    [self.attachmentsService.webService cancellAllOperations];
    [self.attachmentsService removeDelegate:self];
    
    //  NSLog(@"mediapresenters  = %@", self.mediaPresenters);
}

//MARK: - Interface

- (void)configureView:(id<QMMediaViewDelegate>)view
          withMessage:(QBChatMessage *)message {
    
    QBChatAttachment *attachment = [message.attachments firstObject];
    NSParameterAssert(attachment != nil);
    if (!view.mediaHandler) {
        view.mediaHandler = self;
    }
    if (attachment.contentType != QMAttachmentContentTypeAudio) {
        if (view.messageID != nil && ![view.messageID isEqualToString:message.ID]) {
            
            QBChatMessage *messageToCancel = [[QMCore instance].chatService.messagesMemoryStorage messageWithID:view.messageID
                                                                                                   fromDialogID:self.viewController.dialogID];
            [self cancelOperationsForMessage:messageToCancel];
        }
        
    }
    
    [self updateView:view withAttachment:attachment message:message];
}


- (void)updateView:(id<QMMediaViewDelegate>)view
    withAttachment:(QBChatAttachment *)attachment
           message:(QBChatMessage *)message {
    
    view.messageID = message.ID;
    
    if (attachment.duration > 0) {
        view.duration = attachment.duration;
    }
    
    NSString *attStatus = [self.attachmentsService statusForMessage:message];
    
    if (attStatus == QMAttachmentStatus.notLoaded) {
        view.isReady = NO;
        view.isLoading = NO;
        view.progress = 0;
    }
    else if (attStatus == QMAttachmentStatus.loading) {
        
        view.isReady = NO;
        view.isLoading = YES;
        view.progress = [self.attachmentsService.webService progressForMessageWithID:message.ID];
    }
    
    else if (attStatus == QMAttachmentStatus.preparing) {
        view.isLoading = YES;
    }
    
    
    NSLog(@"STATUS FOR MESSAGE ID: %@ %@", message.ID, attStatus);
    
    if (attachment.contentType == QMAttachmentContentTypeImage) {
        
        NSURL *url = [attachment remoteURLWithToken:NO];
        CGSize targetSize  = ((QMBaseMediaCell*)view).previewImageView.bounds.size;
        QMImageTransform *transform  = [QMImageTransform transformWithCustomTransformBlock:^UIImage * _Nullable(NSURL * _Nonnull __unused imageURL, UIImage * _Nonnull originalImage) {
            return  [originalImage imageWithCornerRadius:4 targetSize:targetSize];
        }];
        
        UIImage *image = [QMImageLoader.instance.imageCache imageFromCacheForKey:[transform keyWithURL:url]];
        
        if (image) {
            view.isReady = YES;
            view.image = image;
        }
        else {
            
            view.isReady = NO;
            view.isLoading = YES;
            
            [[QMImageLoader instance] downloadImageWithURL:url
                                                     token:[QBSession currentSession].sessionDetails.token
                                                 transform:transform
                                                   options:SDWebImageHighPriority | SDWebImageContinueInBackground | SDWebImageAllowInvalidSSLCertificates progress:^(NSInteger receivedSize,
                                                                                                                                                                      NSInteger expectedSize,
                                                                                                                                                                      NSURL * _Nullable __unused targetURL)
             {
                 if ([view.messageID isEqualToString:message.ID]) {
                     CGFloat progress = receivedSize/(float)expectedSize;
                     dispatch_async(dispatch_get_main_queue(), ^{
                         view.progress = progress;
                     });
                 }
             } completed:^(UIImage * _Nullable image, UIImage * _Nullable transfomedImage, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nonnull imageURL) {
                 
                 if ([view.messageID isEqualToString:message.ID]) {
                     view.isLoading = NO;
                     if (transfomedImage) {
                         view.isReady = YES;
                         view.image = transfomedImage;
                     }
                     else if (error) {
                         [view showLoadingError:error];
                     }
                 }
                 
             }];
        }
    }
    else if (attachment.contentType == QMAttachmentContentTypeVideo) {
        
        if (attachment.duration) {
            view.duration = attachment.duration;
        }
        UIImage *image = attachment.image;
        
        if (image) {
            view.image = image;
            [QMImageLoader.instance.imageCache storeImage:image forKey:message.ID completion:nil];
        }
        else {
            image = [QMImageLoader.instance.imageCache imageFromCacheForKey:message.ID];
            
            
            if (image) {
                view.image = image;
            }
            else {
                
                view.isLoading = YES;
                [self.attachmentsService.infoService mediaInfoForAttachment:attachment
                                                                  messageID:message.ID
                                                                 completion:^(UIImage * _Nullable image, Float64 durationSeconds, CGSize size, NSError * _Nullable error, NSString * _Nonnull messageID, BOOL cancelled)
                 {
                     
                     
                     
                     if ([view.messageID isEqualToString:messageID]) {
                         if (image) {
                             view.image = image;
                             [QMImageLoader.instance.imageCache storeImage:image forKey:message.ID completion:nil];
                         }
                         if (durationSeconds > 0) {
                             view.duration = lround(durationSeconds);
                         }
                         view.isLoading = NO;
                         view.isReady = error == nil;
                         if (error) {
                             [view showLoadingError:error];
                         }
                     }
                     
                 }];
            }
        }
    }
    
    
    if (attachment.duration > 0) {
        view.duration = attachment.duration;
    }
    
    if (attachment.contentType == QMAttachmentContentTypeAudio || attachment.contentType == QMAttachmentContentTypeVideo) {
        
        BOOL isReady = [self.attachmentsService attachmentIsReadyToPlay:attachment message:message];
        view.isReady = isReady;
        
        if (isReady) {
            
            if (attachment.contentType == QMAttachmentContentTypeAudio) {
                
                QMAudioPlayerStatus *status = [QMAudioPlayer audioPlayer].status;
                
                if ([status.mediaID isEqualToString:message.ID] && status.playerState != QMAudioPlayerStateStopped) {
                    
                    [self updateView:view withPlayerStatus:status];
                }
                else {
                    view.isActive = NO;
                }
            }
        }
        else {
            
            if (attachment.ID == nil) {
                view.isReady = NO;
                return;
            }
            
//            else if (attachment.contentType == QMAttachmentContentTypeVideo) {
//
//                [self.attachmentsService prepareAttachment:attachment messageID:message.ID completion:^(UIImage * _Nullable image, Float64 durationSeconds, CGSize size, NSError * _Nullable error, NSString * _Nonnull messageID, BOOL cancelled) {
//                    view.image = image;
//                }];
//            }
        }
    }
}

- (void)didTapPlayButton:(id<QMMediaViewDelegate>)view {
    
    NSString *messageID = view.messageID;
    NSParameterAssert(messageID);
    
    QBChatMessage *message = [[QMCore instance].chatService.messagesMemoryStorage messageWithID:messageID
                                                                                   fromDialogID:self.viewController.dialogID];
    
    QBChatAttachment *attachment = [message.attachments firstObject];
    if (view.isReady) {
        [self playAttachment:attachment forMessage:message];
    }
}

//MARK: - QMChatAttachmentService Delegate

- (void)chatAttachmentService:(QMChatAttachmentService *)__unused chatAttachmentService
     didChangeLoadingProgress:(CGFloat)progress
                   forMessage:(QBChatMessage *)__unused message
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
    //  [QMImageLoader.instance cancelOperationWithURL:[attachemnt remoteURL]];
    [self.attachmentsService cancelOperationsForAttachment:attachemnt messageID:message.ID];
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
    
    view.isActive = isActive;
    view.duration = status.duration;
    view.currentTime = currentTime;
    
    if (status.playerState == QMAudioPlayerStateStopped) {
        view.duration = status.duration;
    }
}

//MARK: QMEventHandler

- (void)shouldCancelOperation:(id<QMMediaViewDelegate>)view {
    
    NSString *messageID = view.messageID;
    NSParameterAssert(messageID);
    QBChatMessage *message = [[QMCore instance].chatService.messagesMemoryStorage messageWithID:messageID
                                                                                   fromDialogID:self.viewController.dialogID];
    
    [self cancelOperationsForMessage:message];
}

- (void)didTapContainer:(id<QMMediaViewDelegate>)view {
    
    
    NSParameterAssert([view conformsToProtocol:@protocol(QMMediaViewDelegate)]);
    
    NSString *messageID = view.messageID;
    NSParameterAssert(messageID);
    
    QBChatMessage *message = [[QMCore instance].chatService.messagesMemoryStorage messageWithID:messageID
                                                                                   fromDialogID:self.viewController.dialogID];
    
    QBChatAttachment *attachment = [message.attachments firstObject];
    
    NSParameterAssert(attachment);
    
    if (attachment.contentType == QMAttachmentContentTypeImage) {
        
        if (!view.isReady) {
            return;
        }
        
        QBUUser *user =
        [QMCore.instance.usersService.usersMemoryStorage userWithID:message.senderID];
        
        QMPhoto *photo = [[QMPhoto alloc] init];
        
        photo.image = [QMImageLoader.instance originalImageWithURL:[attachment remoteURLWithToken:NO]];
        
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
        
        NYTPhotosViewController *photosViewController =
        [[NYTPhotosViewController alloc] initWithPhotos:@[photo]];
        
        [self.viewController.view endEditing:YES]; // hiding keyboard
        [self.viewController presentViewController:photosViewController
                                          animated:YES
                                        completion:nil];
        
    }
    else if (attachment.contentType == QMAttachmentContentTypeVideo) {
        [self playAttachment:attachment forMessage:message];
    }
    else if (attachment.contentType == QMAttachmentContentTypeAudio) {
        NSString *status = [self.attachmentsService statusForMessage:message];
        if (status == QMAttachmentStatus.loading) {
            view.isLoading = NO;
            [self.attachmentsService.webService cancellOperationWithID:messageID];
        }
        else if (status == QMAttachmentStatus.notLoaded) {
            
            view.isLoading = YES;
            
            [self.attachmentsService attachmentWithID:attachment.ID message:message completion:^(QBChatAttachment * _Nullable attachment, NSError * _Nullable error, QMMessageAttachmentStatus status) {
                if (!error) {
                    view.isReady = YES;
                }
            }];
        }
        else if (status == QMAttachmentStatus.loaded) {
            [self playAttachment:attachment forMessage:message];
        }
    }
    
}

- (void)playAttachment:(QBChatAttachment *)attachment
            forMessage:(QBChatMessage *)message {
    
    if (attachment.contentType == QMAttachmentContentTypeAudio) {
        
        NSURL *fileURL = [self.attachmentsService.storeService fileURLForAttachment:attachment
                                                                          messageID:message.ID
                                                                           dialogID:message.dialogID];
        
        [[QMAudioPlayer audioPlayer] activateMediaAtURL:fileURL withID:message.ID];
    }
    
    if (attachment.contentType == QMAttachmentContentTypeVideo) {
        
        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:[attachment remoteURL]];
        
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
                                            
                                            __strong typeof(weakSelf) strongSelf = weakSelf;
                                            
                                            [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
                                            [strongSelf.videoPlayer play];
                                        }];
    }
}


- (QMChatAttachmentService *)attachmentsService {
    
    return QMCore.instance.chatService.chatAttachmentService;
}


- (void)chatAttachmentService:(QMChatAttachmentService *)__unused chatAttachmentService
          didUpdateAttachment:(QBChatAttachment *)attachment
                  forMesssage:(QBChatMessage *)message {
    id <QMMediaViewDelegate> view = nil;
    
    if ([self.viewController respondsToSelector:@selector(viewForMessage:)]) {
        
        view = [self.viewController viewForMessage:message];
        
        if (view) {
            [self updateView:view
              withAttachment:attachment
                     message:message];
        }
    }
}

- (void)chatAttachmentService:(QMChatAttachmentService *)__unused chatAttachmentService
    didChangeAttachmentStatus:(NSString *)__unused status
                   forMessage:(QBChatMessage *)message {
    
    id <QMMediaViewDelegate> view = nil;
    
    if ([self.viewController respondsToSelector:@selector(viewForMessage:)]) {
        
        view = [self.viewController viewForMessage:message];
        
        if (view) {
            QBChatAttachment *att = message.attachments.firstObject;
            [self updateView:view
              withAttachment:att
                     message:message];
        }
    }
}

@end
