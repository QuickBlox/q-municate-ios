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

@interface QMMediaController() <QMAudioPlayerDelegate, QMPlayerService, QMMediaAssistant>

@property (strong, nonatomic) NSMapTable *attachmentCells;
@property (strong, nonatomic) NSMapTable *mediaViews;
@property (strong, nonatomic) NSMutableDictionary *audioPresenters;
@property (strong, nonatomic) NSMutableDictionary *mediaPresenters;

@end

@implementation QMMediaController

//MARK: - NSObject

- (instancetype)init {
    
    if (self = [super init]) {
        
        _attachmentCells = [NSMapTable strongToWeakObjectsMapTable];
        _mediaViews = [NSMapTable strongToWeakObjectsMapTable];
        _audioPresenters = [NSMutableDictionary dictionary];
        _mediaPresenters = [NSMutableDictionary dictionary];
        
        [QMAudioPlayer audioPlayer].playerDelegate = self;
    }
    
    return  self;
}

- (void)dealloc {
    
    [QMAudioPlayer audioPlayer].playerDelegate = nil;
    
    for (QMMediaPresenter *presenter in self.mediaPresenters.allValues) {
        presenter.mediaAssistant = nil;
        presenter.playerService = nil;
    }
    
    [self.mediaPresenters removeAllObjects];
}

//MARK: - Interface

- (void)bindAttachmentCell:(UIView<QMChatAttachmentCell> *)cell withMessage:(QBChatMessage *)message {
    
    QBChatAttachment* attachment = message.attachments.firstObject;
    
    NSMutableArray* keysToRemove = [NSMutableArray array];
    
    NSEnumerator* enumerator = [self.attachmentCells keyEnumerator];
    NSString* existingAttachmentID = nil;
    
    while (existingAttachmentID = [enumerator nextObject]) {
        
        UICollectionViewCell* cachedCell = [self.attachmentCells objectForKey:existingAttachmentID];
        if ([cachedCell isEqual:cell]) {
            [keysToRemove addObject:existingAttachmentID];
        }
    }
    
    for (NSString* key in keysToRemove) {
        [self.attachmentCells removeObjectForKey:key];
    }
    
    [self.attachmentCells setObject:cell forKey:attachment.ID];
    [cell setAttachmentID:attachment.ID];
    
    [[QMCore instance].chatService.chatAttachmentService imageForAttachmentMessage:message completion:^(NSError *error, UIImage *image) {
        
        if ([cell attachmentID] != attachment.ID) return;
        
        [self.attachmentCells removeObjectForKey:attachment.ID];
        
        if (error != nil) {
            
            if (self.onError) {
                self.onError(message,error);
            }
        }
        else if (image != nil) {
            
            [cell setAttachmentImage:image];
            [cell updateConstraints];
        }
    }];
    
}

- (void)unbindAttachmentCellForMessage:(QBChatMessage *)message {
    
    [self.attachmentCells removeObjectForKey:message.ID];
    // Getting image from chat attachment service.
}


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
    
    //    QMMediaPresenter *presenter = self.mediaPresenters[message.ID];
    //
    //        if (!presenter) {
    //            id <QMMediaViewDelegate> view ;
    //            if (self.viewForMessage)
    //            {
    //                view = self.viewForMessage(message);
    //
    //                if (view) {
    //
    //                    presenter = [[QMMediaPresenter alloc] initWithView:view message:message attachmentID:nil];
    //                    [view setPresenter:presenter];
    //
    //                    self.mediaPresenters[message.ID] = presenter;
    //                }
    //            }
    //        }
    //
    //
    //    [presenter didUpdateProgress:progress];
}


- (void)requestForMediaWithSender:(QMMediaPresenter *)sender {
    
    QBChatMessage *message = sender.message;
    NSString *attachmentID = sender.mediaID;
    
    if (!attachmentID) {
        //Attachment exists only locally
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
                mediaItem.isReady = YES;
                [mediaPresenter updateWithMedia:mediaItem];
                [self.mediaPresenters removeObjectForKey:mediaItem.mediaID];
                //                [[QMCore instance].chatService.chatAttachmentService.mediaService.mediaInfoService imageForMedia:mediaItem completion:^(UIImage *thumbnailImage) {
                //
                //                    QMMediaPresenter *mediaPresenter = self.mediaPresenters[attachmentID];
                //                    mediaItem.isReady = YES;
                //                    [mediaPresenter updateWithMedia:mediaItem];
                //                    [mediaPresenter didUpdateThumbnailImage:thumbnailImage];
                //                    [self.mediaPresenters removeObjectForKey:mediaItem.mediaID];
                //                }];
            }
            
        }];
        
    }
}


- (void)requestForMediaInfoWithSender:(QMMediaPresenter *)sender {
    
    QMMediaItem *item =  [[QMCore instance].chatService.chatAttachmentService.mediaService cachedMediaForMessage:sender.message attachmentID:sender.mediaID];
    if (item) {
        [[QMCore instance].chatService.chatAttachmentService.mediaService.mediaInfoService duration:item completion:^(NSTimeInterval duration) {
            [sender didUpdateDuration:duration];
        }];
        [[QMCore instance].chatService.chatAttachmentService.mediaService.mediaInfoService imageForMedia:item completion:^(UIImage *thumbnailImage) {
            [sender didUpdateThumbnailImage:thumbnailImage];
        }];
    }
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
    
    [[QMAudioPlayer audioPlayer] activateMedia:mediaItem];
    self.audioPresenters[mediaItem.mediaID] = sender;
}

- (void)player:(QMAudioPlayer *__unused)player didChangePlayingStatus:(QMAudioPlayerStatus *)status {
    
    NSString *mediaID = status.mediaID;
    QMMediaPresenter *presenter = self.audioPresenters[mediaID];
    
    [presenter didUpdateIsActive:YES];
    [presenter didUpdateCurrentTime:status.currentTime duration:status.duration];
}



@end
