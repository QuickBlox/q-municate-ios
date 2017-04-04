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


@interface QMMediaController() <QMAudioPlayerDelegate, QMPlayerService, QMMediaAssistant, QMEventHandler, NYTPhotosViewControllerDelegate>

@property (strong, nonatomic) NSMapTable *mediaPresenters;

@property (weak, nonatomic) UIViewController <QMMediaControllerDelegate> *viewController;
@property (strong, nonatomic) QMMediaService *mediaService;
@property (strong, nonatomic) AVPlayer *videoPlayer;

@end

@implementation QMMediaController
@dynamic mediaService;

//MARK: - NSObject

- (instancetype)initWithViewController:(UIViewController <QMMediaControllerDelegate> *)viewController {
    
    if (self = [super init]) {
        
        _mediaPresenters = [NSMapTable strongToWeakObjectsMapTable];
        _viewController = viewController;
        [QMAudioPlayer audioPlayer].playerDelegate = self;
    }
    
    return  self;
}

- (void)cancelOperationsForMessage:(QBChatMessage *)message {
    
    for (QBChatAttachment *att in message.attachments) {
        
    }
}
- (void)dealloc {
    
    [QMAudioPlayer audioPlayer].playerDelegate = nil;
    [self.mediaPresenters removeAllObjects];
}

//MARK: - Interface


- (void)configureView:(id<QMMediaViewDelegate>)view withMessage:(QBChatMessage *)message attachmentID:(NSString *)attachmentID {
    
    QMMediaPresenter *presenter = [self.mediaPresenters objectForKey:attachmentID];
    
    if (presenter == nil) {
        
        presenter = [[QMMediaPresenter alloc] initWithView:view];
        presenter.attachmentID = attachmentID;
        presenter.message = message;
        presenter.mediaAssistant = self;
        presenter.playerService = self;
        presenter.eventHandler = self;
        [self.mediaPresenters setObject:presenter forKey:attachmentID];
    }
    else {
        
        [presenter setView:view];
    }
    
    [view setPresenter:presenter];
    [presenter requestForMedia];
}


//MARK: - QMChatAttachmentService Delegate

- (void)chatAttachmentService:(QMChatAttachmentService *)__unused chatAttachmentService didChangeLoadingProgress:(CGFloat)progress forMessage:(QBChatMessage *)__unused message attachment:(QBChatAttachment *)__unused attachment {
    
    QMMediaPresenter *presenter = [self.mediaPresenters objectForKey:attachment.ID];
    [presenter didUpdateProgress:progress];
}

- (void)chatAttachmentService:(QMChatAttachmentService *)__unused chatAttachmentService didChangeUploadingProgress:(CGFloat)progress forMessage:(QBChatMessage *)message {
    
    QMMediaPresenter *presenter = [self presenterForMessage:message];
    [presenter didUpdateProgress:progress];
}


- (void)requestForMediaWithSender:(QMMediaPresenter *)sender {
    
    QBChatMessage *message = sender.message;
    NSString *attachmentID = sender.attachmentID;
    
    if (!attachmentID) {
        QBChatAttachment *attachment = [self.mediaService placeholderAttachment:message.ID];
        
        if (attachment != nil) {
            
            [self.mediaPresenters setObject:sender forKey:message.ID];
            [self updateWithMedia:attachment
                          message:message
                     attachmentID:attachmentID];
        }
        //        else {
        //            [sender didUpdateIsReady:YES];
        //        }
    }
    else {
        QBChatAttachment *attachment = message.attachments[0];
        
        [self.mediaPresenters setObject:sender forKey:attachmentID];
        [self updateWithMedia:attachment
                      message:message
                 attachmentID:attachmentID];
        
        
    }
}


- (void)updateWithMedia:(QBChatAttachment *)attachment message:(QBChatMessage *)message attachmentID:(NSString *)attachmentID {
    
    if (!attachment) {
        return;
    }
    
    if (attachmentID == nil) {
        
        QMMediaPresenter *presenter = [self presenterForMessage:message];
        [presenter didUpdateIsReady:NO];
        [presenter didUpdateThumbnailImage:attachment.image];
        [presenter didUpdateDuration:attachment.duration];
    }
    else {
        
        QMMediaPresenter *presenter = [self.mediaPresenters objectForKey:attachmentID];
        
        if (attachment.contentType == QMAttachmentContentTypeImage) {
            if (attachment.image) {
                [presenter didUpdateThumbnailImage:attachment.image];
            }
//            else {
//                [presenter didUpdateIsReady:NO];
//                [self.mediaService imageForAttachment:attachment
//                                              message:message
//                                             withSize:CGSizeZero
//                                           completion:^(UIImage *image, NSError *error) {
//                                               if (!error) {
//                                                   [presenter didUpdateIsReady:YES];
//                                                   [presenter didUpdateThumbnailImage:image];
//                                               }
//                                           }];
//            }
        }
        if (attachment.contentType == QMAttachmentContentTypeAudio) {
//            __weak typeof(self) weakSelf = self;
            
//            [self.mediaService audioDataForAttachment:attachment
//                                              message:message
//                                           completion:^(BOOL isReady, NSError *error) {
//                                               __strong typeof(weakSelf) strongSelf = weakSelf;
//                                               if ([strongSelf.viewController respondsToSelector:@selector(didUpdateMessage:)]) {
//                                                   [strongSelf.viewController didUpdateMessage:message];
//                                               }
//                                           }];
            
            [presenter didUpdateDuration:attachment.duration];
            
        }
        if (attachment.contentType == QMAttachmentContentTypeVideo) {
            
            if (attachment.image) {
                [presenter didUpdateThumbnailImage:attachment.image];
            }
//            else {
//                [presenter didUpdateIsReady:NO];
//                [self.mediaService imageForAttachment:attachment
//                                              message:message
//                                             withSize:CGSizeZero completion:^(UIImage *image, NSError *error) {
//                                                 if (!error) {
//                                                     [presenter didUpdateIsReady:YES];
//                                                     [presenter didUpdateThumbnailImage:image];
//                                                 }
//                                             }];
//            }
            
            [presenter didUpdateDuration:attachment.duration];
        }
    }
}

- (void)requestPlayingStatus:(QMMediaPresenter *)sender {
    
    /*
     QMMediaItem *mediaItem = [[QMCore instance].chatService.chatAttachmentService.mediaService
     cachedMediaForMessage:sender.message
     attachmentID:sender.mediaID];
     
     if (mediaItem.contentType == QMMediaContentTypeAudio) {
     QMAudioPlayerStatus *status = [QMAudioPlayer audioPlayer].status;
     
     if ([status.mediaID isEqualToString:sender.mediaID]) {
     
     NSLog(@"requestPlayingStatus\n[sender.mediaID %@]\n[sender.view %p] ", sender.mediaID, sender.view);
     
     [sender didUpdateIsActive:(status.playerStatus == QMPlayerStatusPlaying)];
     
     NSTimeInterval duration = mediaItem.mediaDuration;
     if (duration > 0) {
     
     }
     else {
     duration = status.duration;
     mediaItem.mediaDuration = duration;
     }
     
     if (status.playerStatus != QMPlayerStatusStopped) {
     NSTimeInterval currentTime = status.currentTime;
     [sender didUpdateCurrentTime:currentTime duration:duration];
     }
     }
     else {
     [sender didUpdateIsActive:NO];
     }
     }
     */
}

- (void)activateMediaWithSender:(QMMediaPresenter *)sender {
    /*
     QMMediaItem *mediaItem = [[QMCore instance].chatService.chatAttachmentService.mediaService
     cachedMediaForMessage:sender.message
     attachmentID:sender.mediaID];
     if (mediaItem) {
     //  self.audioPresenters[mediaItem.mediaID] = sender;
     [self playMediaItem:mediaItem];
     }
     */
}

- (void)player:(QMAudioPlayer *__unused)player didChangePlayingStatus:(QMAudioPlayerStatus *)status {
    
    //    NSString *mediaID = status.mediaID;
    //
    //    if (mediaID == nil) {
    //        return;
    //    }
    //
    //    QMMediaPresenter *presenter = [self.mediaPresenters objectForKey:mediaID];
    //    QMPlayerStatus playingStatus = status.playerStatus;
    //
    //    [presenter didUpdateIsActive:(status.playerStatus == QMPlayerStatusPlaying)];
    //
    //    NSLog(@"didChangePlayingStatus\n[sender.mediaID %@]\n[sender.view %p] ", mediaID, presenter.view);
    //
    //    if (playingStatus == QMPlayerStatusStopped) {
    //
    //        [presenter didUpdateCurrentTime:status.duration duration:status.duration];
    //        [presenter didUpdateCurrentTime:0 duration:status.duration];
    //        [presenter didUpdateDuration:status.duration];
    //    }
    //    else {
    //
    //        [presenter didUpdateCurrentTime:status.currentTime duration:status.duration];
    //    }
}


//MARK: QMEventHandler

- (void)didTapContainer:(QMMediaPresenter *)sender {
    
    QBChatAttachment *attachment = sender.message.attachments[0];
    QMMediaItem *mediaItem = nil;//[self.mediaService cachedMediaForMessage:sender.message
    //
    /*attachmentID:sender.mediaID];
     if (!mediaItem) {
     return;
     }
     if (mediaItem.contentType == QMMediaContentTypeImage) {
     __weak typeof(self) weakSelf = self;
     
     [self.mediaService.storeService localImageAttachment:attachment completion:^(UIImage *image) {
     __strong typeof(weakSelf) strongSelf = weakSelf;
     QBChatMessage *currentMessage = sender.message;
     
     QBUUser *user = [[QMCore instance].usersService.usersMemoryStorage userWithID:sender.message.senderID];
     
     QMPhoto *photo = [[QMPhoto alloc] init];
     
     photo.image = image;
     
     NSString *title = user.fullName ?: [NSString stringWithFormat:@"%tu", user.ID];
     photo.attributedCaptionTitle = [[NSAttributedString alloc] initWithString:title
     attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor],
     NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleBody]}];
     
     photo.attributedCaptionSummary = [[NSAttributedString alloc] initWithString:[QMDateUtils formatDateForTimeRange:currentMessage.dateSent]
     attributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor],
     NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleBody]}];
     
     NYTPhotosViewController *photosViewController = [[NYTPhotosViewController alloc] initWithPhotos:@[photo]];
     
     [strongSelf.viewController.view endEditing:YES]; // hiding keyboard
     [strongSelf.viewController presentViewController:photosViewController
     animated:YES
     completion:nil];
     }];
     
     
     
     }
     else {
     
     [self activateMediaWithSender:sender];
     }
     */
}

- (void)playMediaItem:(QMMediaItem *)mediaItem {
    
    if (mediaItem.contentType == QMMediaContentTypeVideo) {
        
        QMMediaInfo *mediaInfo = [self.mediaService.mediaInfoService cachedMediaInfoForItem:mediaItem];
        
        AVPlayerItem *playerItem = nil;
        
        if (mediaInfo.prepareStatus == QMMediaPrepareStatusPrepareFinished) {
            playerItem = mediaInfo.playerItem;
        }
        else {
            playerItem = [AVPlayerItem playerItemWithURL:mediaItem.remoteURL];
        }
        
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
        
        [self.viewController presentViewController:playerVC animated:YES completion:^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf.videoPlayer play];
        }];
    }
    else if (mediaItem.contentType == QMMediaContentTypeAudio) {
        [[QMAudioPlayer audioPlayer] activateMedia:mediaItem];
    }
}


- (void)chatAttachmentService:(QMChatAttachmentService *)__unused chatAttachmentService didChangeAttachmentStatus:(QMMessageAttachmentStatus)status forMessage:(QBChatMessage *)message {
    
    message.attachmentStatus = status;
    
    if ([self.viewController respondsToSelector:@selector(didUpdateMessage:)]) {
        [self.viewController didUpdateMessage:message];
    }
}

- (QMMediaService *)mediaService {
    
    return [QMCore instance].chatService.chatAttachmentService.mediaService;
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
                [view setPresenter:presenter];
                
                [self.mediaPresenters setObject:presenter
                                         forKey:message.ID];
            }
        }
    }
    
    return presenter;
    
}

@end
