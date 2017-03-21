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


@interface QMMediaController() <QMAudioPlayerDelegate, QMPlayerService, QMMediaAssistant, QMEventHandler, NYTPhotosViewControllerDelegate>

@property (strong, nonatomic) NSMutableDictionary *audioPresenters;
@property (strong, nonatomic) NSMapTable *mediaPresenters;

@property (strong, nonatomic) QMChatViewController *viewController;
@property (weak, nonatomic) id photoReferenceView;
@property (strong, nonatomic) QMMediaService *mediaService;
@property (strong, nonatomic) AVPlayer *videoPlayer;
@end

@implementation QMMediaController
@dynamic mediaService;

//MARK: - NSObject

- (instancetype)initWithViewController:(QMChatViewController *)controller {
    
    if (self = [super init]) {
        
        _mediaPresenters = [NSMapTable strongToWeakObjectsMapTable];
        _audioPresenters = [NSMutableDictionary dictionary];
        _viewController = controller;
        [QMAudioPlayer audioPlayer].playerDelegate = self;
    }
    
    return  self;
}

- (void)dealloc {
    
    [QMAudioPlayer audioPlayer].playerDelegate = nil;
    
    self.viewController = nil;
    
    [self.mediaPresenters removeAllObjects];
    
    [self.mediaPresenters removeAllObjects];
}

//MARK: - Interface


- (void)configureView:(id<QMMediaViewDelegate>)view withMessage:(QBChatMessage *)message attachmentID:(NSString *)attachmentID {
    
    NSMutableArray *keysToRemove = [NSMutableArray array];
    
    NSEnumerator *enumerator = [self.mediaPresenters keyEnumerator];
    NSString *existingAttachmentID = nil;
    
    while (existingAttachmentID = [enumerator nextObject]) {
        QMMediaPresenter *presenter = [self.mediaPresenters objectForKey:existingAttachmentID];
        if ([presenter.view isEqual:view]) {
            [keysToRemove addObject:existingAttachmentID];
        }
    }
    
    for (NSString *key in keysToRemove) {
        [self.mediaPresenters removeObjectForKey:key];
    }
    
    
    QMMediaPresenter *presenter = [[QMMediaPresenter alloc] initWithView:view];
    presenter.mediaID = attachmentID;
    presenter.message = message;
    presenter.mediaAssistant = self;
    presenter.playerService = self;
    presenter.eventHandler = self;
    
    [view setPresenter:presenter];
    
    [self.mediaPresenters setObject:presenter forKey:message.ID];
    
    [presenter requestForMedia];
}


//MARK: - QMChatAttachmentService Delegate

- (void)chatAttachmentService:(QMChatAttachmentService *)__unused chatAttachmentService didChangeLoadingProgress:(CGFloat)progress forMessage:(QBChatMessage *)__unused message attachment:(QBChatAttachment *)attachment {
    
    QMMediaPresenter *presenter = [self.mediaPresenters objectForKey:message.ID];
    [presenter didUpdateProgress:progress];
}

- (void)chatAttachmentService:(QMChatAttachmentService *)__unused chatAttachmentService didChangeUploadingProgress:(CGFloat)progress forMessage:(QBChatMessage *)message {
    
    QMMediaPresenter *presenter = [self.mediaPresenters objectForKey:message.ID];
    
    if (!presenter) {
        id <QMMediaViewDelegate> view ;
        if (self.viewForMessage)
        {
            view = self.viewForMessage(message);
            
            if (view) {
                
                presenter = [[QMMediaPresenter alloc] initWithView:view];
                [view setPresenter:presenter];
                
                [self.mediaPresenters setObject:presenter forKey:message.ID];
            }
        }
    }
    
    [presenter didUpdateProgress:progress];
}


- (void)requestForMediaWithSender:(QMMediaPresenter *)sender {
    
    QBChatMessage *message = sender.message;
    NSString *attachmentID = sender.mediaID;
    
    if (!attachmentID) {
        
        QMMediaItem *mediaItem = [self.mediaService placeholderMediaForMessage:message];
        [self.mediaPresenters setObject:sender forKey:message.ID];
        [self updateWithMedia:mediaItem message:message mediaID:attachmentID];
    }
    else {
        
        __weak typeof(self) weakSelf = self;
        [self.mediaService mediaForMessage:message attachmentID:attachmentID withCompletionBlock:^(QMMediaItem *mediaItem, NSError *error) {
            if (!error) {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                [strongSelf updateWithMedia:mediaItem message:message mediaID:attachmentID];
            }
        }];
    }
}


- (void)updateWithMedia:(QMMediaItem *)mediaItem message:(QBChatMessage *)message mediaID:(NSString *)mediaID {
    if (!mediaItem) {
        return;
    }
    if (mediaID == nil) {
        
        QMMediaPresenter *presenter = [self.mediaPresenters objectForKey:message.ID];
        
        if (!presenter) {
            id <QMMediaViewDelegate> view ;
            if (self.viewForMessage)
            {
                view = self.viewForMessage(message);
                
                if (view) {
                    
                    presenter = [[QMMediaPresenter alloc] initWithView:view];
                    [view setPresenter:presenter];
                    
                    [self.mediaPresenters setObject:presenter forKey:message.ID];
                }
            }
        }
        [presenter didUpdateThumbnailImage:mediaItem.image];
        [presenter didUpdateDuration:mediaItem.mediaDuration];
        
    }
    else {
        
        QMMediaPresenter *presenter = [self.mediaPresenters objectForKey:message.ID];
        
        [presenter didUpdateIsReady:YES];
        
        if (mediaItem.contentType == QMMediaContentTypeImage) {
            if (mediaItem.image) {
                [presenter didUpdateThumbnailImage:mediaItem.image];
            }
            else {
                [self.mediaService.storeService localImageForMediaItem:mediaItem completion:^(UIImage *image) {
                    [presenter didUpdateThumbnailImage:image];
                }];
            }
        }
        if (mediaItem.contentType == QMMediaContentTypeAudio) {
            [presenter didUpdateDuration:mediaItem.mediaDuration];
        }
        if (mediaItem.contentType == QMMediaContentTypeVideo) {
            
            if (mediaItem.image) {
                [presenter didUpdateThumbnailImage:mediaItem.image];
            }
            else {
                [self.mediaService.mediaInfoService localThumbnailForMediaItem:mediaItem completion:^(UIImage *image) {
                    [presenter didUpdateThumbnailImage:image];
                }];
            }
            
            [presenter didUpdateDuration:mediaItem.mediaDuration];
        }
        
    }
    
}

- (void)requestPlayingStatus:(QMMediaPresenter *)sender {
    
    QMMediaItem *mediaItem = [[QMCore instance].chatService.chatAttachmentService.mediaService
                              cachedMediaForMessage:sender.message
                              attachmentID:sender.mediaID];
    
    if (mediaItem.contentType == QMMediaContentTypeAudio) {
        QMAudioPlayerStatus *status = [QMAudioPlayer audioPlayer].status;
        
        if ([status.mediaID isEqualToString:sender.mediaID]) {
        [sender didUpdateIsActive:(status.playerStatus == QMPlayerStatusPlaying)];
        
        if (status.playerStatus != QMPlayerStatusStopped) {
                NSTimeInterval duration = status.duration;
                NSTimeInterval currentTime = status.currentTime;
                [sender didUpdateCurrentTime:currentTime duration:duration];
            }
        }
        else {
            [sender didUpdateIsActive:NO];
        }
    }
}

- (void)activateMediaWithSender:(QMMediaPresenter *)sender {
    
    QMMediaItem *mediaItem = [[QMCore instance].chatService.chatAttachmentService.mediaService
                              cachedMediaForMessage:sender.message
                              attachmentID:sender.mediaID];
    if (mediaItem) {
        self.audioPresenters[mediaItem.mediaID] = sender;
        [self playMediaItem:mediaItem];
    }
}

- (void)player:(QMAudioPlayer *__unused)player didChangePlayingStatus:(QMAudioPlayerStatus *)status {
    
    NSString *mediaID = status.mediaID;
    
    if (mediaID == nil) {
        return;
    }
    
    QMMediaPresenter *presenter = self.audioPresenters[mediaID];
    QMPlayerStatus playingStatus = status.playerStatus;

    [presenter didUpdateIsActive:(status.playerStatus == QMPlayerStatusPlaying)];
    
    if (playingStatus == QMPlayerStatusStopped) {
        
        [presenter didUpdateCurrentTime:0.0 duration:status.duration];
        [presenter didUpdateDuration:status.duration];
        [self.audioPresenters removeObjectForKey:mediaID];
    }
    else {
        
        [presenter didUpdateCurrentTime:status.currentTime duration:status.duration];
    }
}


//MARK: QMEventHandler

- (void)didTapContainer:(QMMediaPresenter *)sender {
    
    QMMediaItem *mediaItem = [self.mediaService cachedMediaForMessage:sender.message
                                                         attachmentID:sender.mediaID];
    if (!mediaItem) {
        return;
    }
    if (mediaItem.contentType == QMMediaContentTypeImage) {
        __weak typeof(self) weakSelf = self;
      
        [self.mediaService.storeService localImageForMediaItem:mediaItem completion:^(UIImage *image) {
              __strong typeof(weakSelf) strongSelf = weakSelf;
            QBChatMessage *currentMessage = sender.message;
            
            QBUUser *user = [[QMCore instance].usersService.usersMemoryStorage userWithID:sender.message.senderID];
            
            QMPhoto *photo = [[QMPhoto alloc] init];
            
            photo.image = image;
            
            NSString *title = user.fullName ?: [NSString stringWithFormat:@"%tu", user.ID];
            photo.attributedCaptionTitle = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleBody]}];
            
            photo.attributedCaptionSummary = [[NSAttributedString alloc] initWithString:[QMDateUtils formatDateForTimeRange:currentMessage.dateSent] attributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor], NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleBody]}];
            
            NYTPhotosViewController *photosViewController = [[NYTPhotosViewController alloc] initWithPhotos:@[photo]];
            
            [strongSelf.viewController.view endEditing:YES]; // hiding keyboard
            [strongSelf.viewController presentViewController:photosViewController animated:YES completion:nil];
        }];
        

        
    }
    else {
        [self activateMediaWithSender:sender];
    }
    

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
    if (self.onMessageStatusDidChange) {
        self.onMessageStatusDidChange(status, message);
    }
}
//MARK: - NYTPhotosViewControllerDelegate

- (UIView *)photosViewController:(NYTPhotosViewController *)__unused photosViewController referenceViewForPhoto:(id<NYTPhoto>)__unused photo {
    
    return self.photoReferenceView;
}

- (QMMediaService *)mediaService {
    
    return [QMCore instance].chatService.chatAttachmentService.mediaService;
}

@end
