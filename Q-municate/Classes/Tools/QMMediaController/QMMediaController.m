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

@property (strong, nonatomic) NSMapTable *attachmentCells;
@property (strong, nonatomic) NSMapTable *mediaViews;
@property (strong, nonatomic) NSMutableDictionary *audioPresenters;
@property (strong, nonatomic) NSMutableDictionary *mediaPresenters;

@property (strong, nonatomic) UIViewController *viewController;
@property (weak, nonatomic) id photoReferenceView;

@end

@implementation QMMediaController

//MARK: - NSObject

- (instancetype)initWithViewController:(UIViewController *)controller {
    
    if (self = [super init]) {
        
        _mediaViews = [NSMapTable strongToWeakObjectsMapTable];
        _audioPresenters = [NSMutableDictionary dictionary];
        _mediaPresenters = [NSMutableDictionary dictionary];
        
        _viewController = controller;
        [QMAudioPlayer audioPlayer].playerDelegate = self;
    }
    
    return  self;
}

- (void)dealloc {
    
    [QMAudioPlayer audioPlayer].playerDelegate = nil;
    self.viewController = nil;
    
    for (QMMediaPresenter *presenter in self.mediaPresenters.allValues) {
        presenter.mediaAssistant = nil;
        presenter.playerService = nil;
    }
    
    [self.mediaPresenters removeAllObjects];
}

//MARK: - Interface

- (id<QMMediaViewDelegate>)bindView:(id<QMMediaViewDelegate>)view withMessage:(QBChatMessage *)message attachmentID:(NSString *)attachmentID {
    
    if (!attachmentID.length) {
        
        return view;
    }
    
    QMMediaPresenter *presenter = [self.mediaPresenters objectForKey:attachmentID];
    
    if (!presenter) {
        
        presenter = [[QMMediaPresenter alloc] initWithView:view];
        presenter.mediaID = attachmentID;
        presenter.message = message;
        presenter.mediaAssistant = self;
        presenter.playerService = self;
        presenter.eventHandler = self;
        
    }
    else {
        presenter.view = view;
    }
    
    [view setPresenter:presenter];
    
    [presenter requestForMedia];
    
    return view;
}


- (void)unbindViewWithAttachment:(QBChatAttachment *)attachment {
    
    QMMediaPresenter *mediaPresenter = self.mediaPresenters[attachment.ID];
    
    if (mediaPresenter) {
        [mediaPresenter setView:nil];
    }
    
    QMMediaPresenter *audioPresenter = self.audioPresenters[attachment.ID];
    if (audioPresenter) {
        [audioPresenter setView:nil];
    }
}

//MARK: - QMChatAttachmentService Delegate

- (void)chatAttachmentService:(QMChatAttachmentService *)__unused chatAttachmentService didChangeLoadingProgress:(CGFloat)progress forMessage:(QBChatMessage *)__unused message attachment:(QBChatAttachment *)attachment {
    
    QMMediaPresenter *presenter = self.mediaPresenters[attachment.ID];
    [presenter didUpdateProgress:progress];
}

- (void)chatAttachmentService:(QMChatAttachmentService *)__unused chatAttachmentService didChangeUploadingProgress:(CGFloat)progress forMessage:(QBChatMessage *)message {
    
    QMMediaPresenter *presenter = self.mediaPresenters[message.ID];
    
    if (!presenter) {
        id <QMMediaViewDelegate> view ;
        if (self.viewForMessage)
        {
            view = self.viewForMessage(message);
            
            if (view) {
                
                presenter = [[QMMediaPresenter alloc] initWithView:view];
                [view setPresenter:presenter];
                
                self.mediaPresenters[message.ID] = presenter;
            }
        }
    }
    
    
    [presenter didUpdateProgress:progress];
}


- (void)requestForMediaWithSender:(QMMediaPresenter *)sender {
    
    QBChatMessage *message = sender.message;
    NSString *attachmentID = sender.mediaID;
    
    if (!attachmentID) {
        
        QBChatAttachment *currentAttachment;
        
        QMMediaItem *localItem = [QMMediaItem new];
        for (QBChatAttachment *attachment in message.attachments) {
            if (attachment.ID  == nil) {
                currentAttachment = attachment;
            }
        }
        
        [localItem updateWithAttachment:currentAttachment];
        
        [[QMCore instance].chatService.chatAttachmentService.mediaService.mediaInfoService mediaInfoForItem:localItem completion:^(QMMediaInfo *mediaInfo) {
            localItem.videoSize = mediaInfo.mediaSize;
            localItem.duration = mediaInfo.duration;
            
            [sender updateWithMediaItem:localItem];
        }];
        
        if (localItem.contentType == QMMediaContentTypeVideo) {
            [[QMCore instance].chatService.chatAttachmentService.mediaService.mediaInfoService imageForMedia:localItem completion:^(UIImage *image) {
                [sender didUpdateThumbnailImage:image];
            }];
        }
    }
    else {
        
        QMMediaPresenter *presenter = self.mediaPresenters[attachmentID];
        
        if (presenter) {
            
        }
        else {
            
            self.mediaPresenters[attachmentID] = sender;
        }
        
        
        [[QMCore instance].chatService.chatAttachmentService.mediaService mediaForMessage:message attachmentID:attachmentID withCompletionBlock:^(QMMediaItem *mediaItem, NSError *error) {
            
            if (![attachmentID isEqualToString:mediaItem.mediaID]) {
                return ;
            }
            
            
            if (error != nil) {
                if (self.onError) {
                    self.onError(message,error);
                }
            }
            else if (mediaItem != nil) {
                
                QMMediaPresenter *mediaPresenter = self.mediaPresenters[attachmentID];
                
                if (mediaItem.contentType == QMMediaContentTypeVideo || mediaItem == QMMediaContentTypeAudio) {
                    
                    [[QMCore instance].chatService.chatAttachmentService.mediaService mediaInfoForItem:mediaItem completion:^(QMMediaInfo *mediaInfo, UIImage *image) {
                        
                        mediaItem.videoSize = mediaInfo.mediaSize;
                        mediaItem.duration = mediaInfo.duration;
                        mediaItem.isReady = mediaInfo.isReady;
    
                        [mediaPresenter didUpdateIsReady:mediaInfo.isReady];
                        [mediaPresenter didUpdateThumbnailImage:image];
                        [mediaPresenter updateWithMediaItem:mediaItem];
                    }];
                }
                
                
                if (mediaItem.contentType == QMMediaContentTypeImage) {
                    [[QMCore instance].chatService.chatAttachmentService.mediaService  imageForMediaItem:mediaItem completion:^(UIImage *image) {
                        [mediaPresenter didUpdateIsReady:YES];
                        [mediaPresenter didUpdateThumbnailImage:image];
                    }];
                }
                
            }
        }];
        
    }
}


- (void)requestForMediaInfoWithSender:(QMMediaPresenter *)sender {
    
}

- (void)requestPlayingStatus:(QMMediaPresenter *)sender {
    
    QMAudioPlayerStatus *status = [QMAudioPlayer audioPlayer].status;
    BOOL isActive = [status.mediaID isEqualToString:sender.mediaID];
    
    if (isActive) {
        [sender didUpdateIsActive:isActive];
    }
}

- (void)activateMediaWithSender:(QMMediaPresenter *)sender {
    
    QMMediaItem *mediaItem = [[QMCore instance].chatService.chatAttachmentService.mediaService
                              cachedMediaForMessage:sender.message
                              attachmentID:sender.mediaID];
    if (mediaItem) {
        [[QMAudioPlayer audioPlayer] activateMedia:mediaItem];
        self.audioPresenters[mediaItem.mediaID] = sender;
    }
}

- (void)player:(QMAudioPlayer *__unused)player didChangePlayingStatus:(QMAudioPlayerStatus *)status {
    
    NSString *mediaID = status.mediaID;
    QMMediaPresenter *presenter = self.audioPresenters[mediaID];
    
    [presenter didUpdateIsActive:YES];
    [presenter didUpdateCurrentTime:status.currentTime duration:status.duration];
}


//MARK: QMEventHandler

- (void)didTapContainer:(QMMediaPresenter *)sender {
    
    QBChatAttachment *attachment = sender.message.attachments[0];
    QMMediaItem *mediaItem = [QMMediaItem new];
    [mediaItem updateWithAttachment:attachment];
    
    if (mediaItem.contentType == QMMediaContentTypeImage) {
        [[QMCore instance].chatService.chatAttachmentService.mediaService.storeService localImageFromMediaItem:mediaItem completion:^(UIImage *image) {
            
            if (image) {
                
                QBChatMessage *currentMessage = sender.message;
                
                QBUUser *user = [[QMCore instance].usersService.usersMemoryStorage userWithID:sender.message.senderID];
                
                QMPhoto *photo = [[QMPhoto alloc] init];
                
                photo.image = image;
                
                NSString *title = user.fullName ?: [NSString stringWithFormat:@"%tu", user.ID];
                photo.attributedCaptionTitle = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleBody]}];
                
                photo.attributedCaptionSummary = [[NSAttributedString alloc] initWithString:[QMDateUtils formatDateForTimeRange:currentMessage.dateSent] attributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor], NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleBody]}];
                
                //self.photoReferenceView = [sender view];
                
                NYTPhotosViewController *photosViewController = [[NYTPhotosViewController alloc] initWithPhotos:@[photo]];
                photosViewController.delegate = self;
                
                [self.viewController.view endEditing:YES]; // hiding keyboard
                [self.viewController presentViewController:photosViewController animated:YES completion:nil];

            }
        }];
        
        return;
    }
    
    
    
    [[QMCore instance].chatService.chatAttachmentService.mediaService mediaInfoForItem:mediaItem completion:^(QMMediaInfo *mediaInfo, UIImage *image) {
        
        if (mediaInfo.isReady) {
            
            switch (mediaItem.contentType) {
                    
                case QMMediaContentTypeVideo: {
                    
                    if (mediaInfo.isReady) {
                        
                        AVPlayer *player = [[AVPlayer alloc] initWithURL:mediaItem.remoteURL];
                        
                        AVPlayerViewController *playerVC = [AVPlayerViewController new];
                        playerVC.player = player;
                        
                        
                        [self.viewController presentViewController:playerVC animated:YES completion:^{
                            [player play];
                        }];
                    }
                    
                    break;
                }
                    
                case QMMediaContentTypeAudio: {
                    
                    if (mediaItem.isReady) {
                        
                        AVPlayer *player = [[AVPlayer alloc] initWithURL:mediaItem.remoteURL];
                        
                        AVPlayerViewController *playerVC = [AVPlayerViewController new];
                        playerVC.player = player;
                        
                        
                        [self.viewController presentViewController:playerVC animated:YES completion:^{
                            [player play];
                        }];
                    }
                    break;
                }
                case QMMediaContentTypeImage: {
                    
                    
                    
                        break;
                    
                }
                case QMMediaContentTypeCustom:
                    break;
                default:
                    break;
            }
            
        }
    }];
    
    return;
    
}





//MARK: - NYTPhotosViewControllerDelegate

- (UIView *)photosViewController:(NYTPhotosViewController *)__unused photosViewController referenceViewForPhoto:(id<NYTPhoto>)__unused photo {
    
    return self.photoReferenceView;
}

@end
