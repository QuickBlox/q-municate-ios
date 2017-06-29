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
    
    view.mediaHandler = self;
    
    
    //    QMMediaPresenter *presenter = [self.mediaPresenters objectForKey:message.ID];
    //
    //    if (![view.presenter.message.ID isEqualToString:message.ID]) {
    //
    //        [self shouldCancellOperationWithSender:view.presenter];
    //    }
    //
    //    if (presenter == nil) {
    //
    //        presenter = [[QMMediaPresenter alloc] initWithView:view];
    //        presenter.message = message;
    //        presenter.modelID = attachment.ID;
    //        presenter.mediaAssistant = self;
    //        presenter.playerService = self;
    //        presenter.eventHandler = self;
    //       // NSLog(@"CREATE ID: %@ presenter: %p view: %p",message.ID, presenter, view);
    //    }
    //    else {
    //        [presenter setView:view];
    //     //   NSLog(@"UPDATE ID: %@ presenter: %p view: %p",message.ID, presenter, view);
    //    }
    //
    //    [view setPresenter:presenter];
    //
    //    [self.mediaPresenters setObject:presenter
    //                             forKey:message.ID];
    //
    //    [presenter requestForMedia];
    
    [self updateView:view withAttachment:attachment message:message];
}

- (void)updateView:(id<QMMediaViewDelegate>)view
    withAttachment:(QBChatAttachment *)attachment
           message:(QBChatMessage *)message {
    
    if (![view.messageID isEqualToString:message.ID]) {
        
        //[self cancelOperationsForMessage:message];
        view.messageID = message.ID;
    }
    //Status for attachment
    //if not loaded
    
    if (attachment.image) {
        view.image = attachment.image;
    }
    else {
        [self.attachmentsService imageForAttachment:attachment
                                            message:message
                                         completion:^(UIImage * _Nonnull image,
                                                      QMMediaError * _Nonnull
                                                      error) {
                                             
                                             if (image) {
                                                 //   id <QMMediaViewDelegate> view = [self.viewController viewForMessage:message];
                                                 view.image = image;
                                                 view.isReady = YES;
                                             }
                                             else if (error) {
                                                 [view showLoadingError:error];
                                             }
                                         }];
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
            
            [self.attachmentsService attachmentWithID:attachment.ID message:message completion:^(QBChatAttachment * _Nullable attachment, NSError * _Nullable error, QMMessageAttachmentStatus status) {
                if (!error) {
                    view.isReady = YES;
                }
            }];
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
    
    //    QMMediaPresenter *presenter = [self presenterForMessage:message];
    //    [presenter didUpdateProgress:progress];
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

- (void)shouldCancellOperationWithSender:(QMMediaPresenter *)sender {
    
    QBChatMessage *message = sender.message;
    QBChatAttachment *attachemnt = [message.attachments firstObject];
    return;
    [self.attachmentsService cancelOperationsForAttachment:attachemnt messageID:message.ID];
}

- (void)requestForMediaWithSender:(QMMediaPresenter *)presenter {
    
    QBChatMessage *message = presenter.message;
    QBChatAttachment *attachment = [message.attachments firstObject];
    
    if (!attachment.ID) {
//        attachment = [self.attachmentsService placeholderAttachment:message.ID];
//        [self updateWithMedia:attachment
//                      message:message];
    }
    else {
        
        //        if (message.attachmentStatus == QMMessageAttachmentStatusNotLoaded) {
        
        
        __weak typeof(self) weakSelf = self;
        NSLog(@"_ASK TO GET %@ %@", message.ID, attachment.ID);
        [self.attachmentsService attachmentWithID:attachment.ID
                                          message:message
                                       completion:^(QBChatAttachment * _Nullable att,
                                                    NSError * _Nullable error,
                                                    QMMessageAttachmentStatus status) {
                                           
                                           
                                           __strong typeof(weakSelf) strongSelf = weakSelf;
                                           if (att) {
                                               NSLog(@"_DID GET %@ %@", message.ID, attachment.ID);
                                               message.attachmentStatus = status;
//                                               [strongSelf updateWithMedia:att
//                                                                   message:message];
                                           }
                                       }];
    }
    //        else if (message.attachmentStatus == QMMessageAttachmentStatusLoaded || message.attachmentStatus == QMMessageAttachmentStatusPrepared) {
    //
    //            QBChatAttachment *attahcment = [self.attachmentsService.storeService cachedAttachmentWithID:attachment.ID
    //                                                                                           forMessageID:message.ID];
    //            [self updateWithMedia:attahcment
    //                          message:message];
    //        }
    //    }
}

- (void)requestPlayingStatus:(QMMediaPresenter *)sender {
    
    QBChatMessage *message = sender.message;
    NSString *attachmentID = sender.modelID;
    
    QBChatAttachment *attachment;
    for (QBChatAttachment *att in message.attachments) {
        if ([att.ID isEqualToString:attachmentID]) {
            attachment = att;
            break;
        }
    }
    
    BOOL isReady = [self.attachmentsService attachmentIsReadyToPlay:attachment
                                                            message:message];
    if (!isReady) {
        return;
    }
    
    if (attachment.contentType == QMAttachmentContentTypeAudio) {
        
        QMAudioPlayerStatus *status = [QMAudioPlayer audioPlayer].status;
        
        if ([status.mediaID isEqualToString:message.ID] && status.playerState != QMAudioPlayerStateStopped) {
            
            [sender didUpdateIsActive:(status.playerState == QMAudioPlayerStatePlaying)];
            
            NSTimeInterval duration = attachment.duration;
            
            if (attachment.duration == 0) {
                duration = status.duration;
                attachment.duration = lrint(duration);
            }
            
            [sender didUpdateCurrentTime:status.currentTime duration:duration];
        }
        else {
            [sender didUpdateCurrentTime:0 duration:attachment.duration];
            [sender didUpdateIsActive:NO];
            [sender didUpdateDuration:attachment.duration];
        }
    }
}

- (void)activateMediaWithSender:(QMMediaPresenter *)sender {
    
    QBChatMessage *message = sender.message;
    NSString *attachmentID = sender.modelID;
    
    QBChatAttachment *attachment;
    for (QBChatAttachment *att in message.attachments) {
        if ([att.ID isEqualToString:attachmentID]) {
            attachment = att;
            break;
        }
    }
    
    BOOL isReady = [self.attachmentsService attachmentIsReadyToPlay:attachment
                                                            message:message];
    
    if (!isReady) {
        return;
    }
    
    [self playAttachment:attachment forMessage:message];
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
             
             photo.image = view.image;
             
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
    else if (attachment.contentType == QMAttachmentContentTypeVideo
             || attachment.contentType == QMAttachmentContentTypeAudio) {
        
        [self playAttachment:attachment forMessage:message];
    }
    
}

- (void)playAttachment:(QBChatAttachment *)attachment
            forMessage:(QBChatMessage *)message {
    
    if (attachment.contentType == QMAttachmentContentTypeAudio) {
        
        NSURL *fileURL = [self.attachmentsService.storeService fileURLForAttachment:attachment messageID:message.ID dialogID:message.dialogID];
        
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

@end
