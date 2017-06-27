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
NYTPhotosViewControllerDelegate>

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
    
    QMMediaPresenter *presenter = [self.mediaPresenters objectForKey:message.ID];
    
    if (view.presenter) {
        
        [self shouldCancellOperationWithSender:view.presenter];
    }
    
    if (presenter == nil) {
        
        presenter = [[QMMediaPresenter alloc] initWithView:view];
        presenter.message = message;
        presenter.modelID = attachment.ID;
        presenter.mediaAssistant = self;
        presenter.playerService = self;
        presenter.eventHandler = self;
       // NSLog(@"CREATE ID: %@ presenter: %p view: %p",message.ID, presenter, view);
    }
    else {
        [presenter setView:view];
     //   NSLog(@"UPDATE ID: %@ presenter: %p view: %p",message.ID, presenter, view);
    }
    
    [view setPresenter:presenter];
    
    [self.mediaPresenters setObject:presenter
                             forKey:message.ID];

    [presenter requestForMedia];
}


//MARK: - QMChatAttachmentService Delegate

- (void)chatAttachmentService:(QMChatAttachmentService *)__unused chatAttachmentService
     didChangeLoadingProgress:(CGFloat)progress
                   forMessage:(QBChatMessage *)__unused message
                   attachment:(QBChatAttachment *)__unused attachment {
    
    QMMediaPresenter *presenter = [self presenterForMessage:message];
    [presenter didUpdateProgress:progress];
}

- (void)chatAttachmentService:(QMChatAttachmentService *)__unused chatAttachmentService
   didChangeUploadingProgress:(CGFloat)progress
                   forMessage:(QBChatMessage *)message {
    
    QMMediaPresenter *presenter = [self presenterForMessage:message];
    [presenter didUpdateProgress:progress];
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
        attachment = [self.attachmentsService placeholderAttachment:message.ID];
        [self updateWithMedia:attachment
                      message:message];
    }
    else {
        
        if (message.attachmentStatus == QMMessageAttachmentStatusNotLoaded) {
            [presenter didUpdateIsReady:NO];
            __weak typeof(self) weakSelf = self;
            
            [self.attachmentsService attachmentWithID:attachment.ID
                                              message:message
                                           completion:^(QBChatAttachment * _Nullable att,
                                                        NSError * _Nullable __unused error) {
                                               
                                               __strong typeof(weakSelf) strongSelf = weakSelf;
                                               if (att) {
                                                   [strongSelf updateWithMedia:att
                                                                       message:message];
                                               }
                                               else {
                                                   
                                               }
                                               
                                           }];
        }
        else if (message.attachmentStatus == QMMessageAttachmentStatusLoaded || message.attachmentStatus == QMMessageAttachmentStatusPrepared) {
            
            QBChatAttachment *attahcment = [self.attachmentsService.storeService cachedAttachmentWithID:attachment.ID
                                                                                           forMessageID:message.ID];
            [self updateWithMedia:attahcment
                          message:message];
        }
    }
}


- (void)updateWithMedia:(QBChatAttachment *)attachment
                message:(QBChatMessage *)message {
    
    QMMediaPresenter *presenter = [self presenterForMessage:message];
    
    if (!attachment.ID) {
      //  NSLog(@"NO ID: DidUpdateMedia presenter:%@ status:%d", presenter, message.attachmentStatus);
        [presenter didUpdateImage:attachment.image];
        [presenter didUpdateDuration:attachment.duration];
    }
    else {
        
        
        [presenter didUpdateIsReady:message.attachmentStatus == QMMessageAttachmentStatusLoaded];
        
      //  NSLog(@"ID: DidUpdateMedia presenter:%@ status:%d view %p", presenter, message.attachmentStatus, presenter.view);
        [presenter didUpdateThumbnailImage:attachment.image];
        [presenter didUpdateDuration:attachment.duration];
    }
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
    
    QMMediaPresenter *presenter = [self.mediaPresenters objectForKey:mediaID];
    QMAudioPlayerState playerState = status.playerState;
    NSLog(@"ID: %@; view: %p; presenter: %p", mediaID, presenter.view, presenter);
    [presenter didUpdateIsActive:(playerState == QMAudioPlayerStatePlaying)];
    
    NSTimeInterval currentTime =
    status.playerState == QMAudioPlayerStateStopped ? 0.0 : status.currentTime;
    
    [presenter didUpdateCurrentTime:currentTime
                           duration:status.duration];
    
    if (status.playerState == QMAudioPlayerStateStopped) {
        [presenter didUpdateDuration:status.duration];
    }
}


//MARK: QMEventHandler

- (void)didTapContainer:(id<QMChatPresenterDelegate>)sender {
    
    QBChatMessage *message = sender.message;
    QBChatAttachment *attachment = [message.attachments firstObject];
    NSLog(@"Atatchment ID = %@", attachment.ID);
    NSLog(@"Message ID = %@", message.ID);
    NSLog(@"Atatchment status = %d", message.attachmentStatus);
    
    NSParameterAssert(attachment);
    
    if (attachment.contentType == QMAttachmentContentTypeImage) {
        __weak typeof(self) weakSelf = self;
        
        
        [self.attachmentsService.storeService cachedImageForAttachment:attachment
                                                             messageID:message.ID
                                                              dialogID:message.dialogID
                                                            completion:^(UIImage *image)
         {
             __strong typeof(weakSelf) strongSelf = weakSelf;
             
             QBUUser *user =
             [[QMCore instance].usersService.usersMemoryStorage userWithID:sender.message.senderID];
             
             QMPhoto *photo = [[QMPhoto alloc] init];
             
             photo.image = image;
             
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
             
             [strongSelf.viewController.view endEditing:YES]; // hiding keyboard
             [strongSelf.viewController presentViewController:photosViewController
                                                     animated:YES
                                                   completion:nil];
         }];
    }
    else if (attachment.contentType == QMAttachmentContentTypeVideo
             || attachment.contentType == QMAttachmentContentTypeAudio) {
        
        [sender activateMedia];
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

- (void)chatAttachmentService:(QMChatAttachmentService *)__unused chatAttachmentService
    didChangeAttachmentStatus:(QMMessageAttachmentStatus)status
                   forMessage:(QBChatMessage *)message {
    
    
    QMMediaPresenter *presenter =  [self presenterForMessage:message];
    
    if (presenter) {
        if (presenter.message.attachmentStatus != status) {
            presenter.message = message;
            presenter.modelID = [[message attachments] firstObject].ID;
            [self.mediaPresenters setObject:presenter
                                     forKey:message.ID];
        //    NSLog(@"UPDATE presenter: %@ view: %p", presenter, presenter.view);
            [presenter requestForMedia];
        }
    }
    
    //    if ([self.viewController respondsToSelector:@selector(didUpdateMessage:)]) {
    //        [self.viewController didUpdateMessage:message];
    //    }
}

- (QMChatAttachmentService *)attachmentsService {
    
    return [QMCore instance].chatService.chatAttachmentService;
}

//MARK:- Helpers

- (QMMediaPresenter *)presenterForMessage:(QBChatMessage *)message {
    
    QMMediaPresenter *presenter = [self.mediaPresenters objectForKey:message.ID];
    
    if (!presenter) {
        
        id <QMMediaViewDelegate> view = nil;
        
        if ([self.viewController respondsToSelector:@selector(viewForMessage:)])
        {
            view = [self.viewController viewForMessage:message];
            
            if (view) {
                
                presenter = [[QMMediaPresenter alloc] initWithView:view];
                presenter.message = message;
                [view setPresenter:presenter];
                presenter.mediaAssistant = self;
                presenter.playerService = self;
                presenter.eventHandler = self;
                NSLog(@"presenterForMessage presenter: %@ view: %p", presenter, view);
                [self.mediaPresenters setObject:presenter
                                         forKey:message.ID];
            }
        }
    }
    
    return presenter;
}

@end
