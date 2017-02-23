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
#import "QMMediaInteractor.h"
#import "QMAudioPlayer.h"

@interface QMMediaController() <QMAudioPlayerDelegate, QMPlayerService>

@property (strong, nonatomic) NSMapTable *attachmentCells;
@property (strong, nonatomic) NSMapTable *mediaViews;
@property (strong, nonatomic) NSMutableDictionary *audioInteractors;
@property (strong, nonatomic) NSMutableDictionary *mediaInteractors;

@end

@implementation QMMediaController

//MARK: - NSObject

- (instancetype)init {
    
    if (self = [super init]) {
        
        _attachmentCells = [NSMapTable strongToWeakObjectsMapTable];
        _mediaViews = [NSMapTable strongToWeakObjectsMapTable];
        _audioInteractors = [NSMutableDictionary dictionary];
        _mediaInteractors = [NSMutableDictionary dictionary];
        
        [QMAudioPlayer audioPlayer].playerDelegate = self;
    }
    //    [QMCore instance].chatService.chatAttachmentService.mediaService
        
        return  self;
}

- (void)dealloc {
    
    [QMAudioPlayer audioPlayer].playerDelegate = nil;
    [[QMCore instance].chatService.chatAttachmentService removeDelegate:self];
    
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


- (void)bindView:(id<QMMediaViewDelegate>)view withMessage:(QBChatMessage *)message {
    
    
    QBChatAttachment *attachment = message.attachments.firstObject;
    
    
    
    //    NSMutableArray *keysToRemove = [NSMutableArray array];
    //
    //    NSEnumerator *enumerator = [self.mediaViews keyEnumerator];
    //
    //    NSString *existingAttachmentID = nil;
    //
    //    while (existingAttachmentID = [enumerator nextObject]) {
    //
    //        id<QMMediaViewDelegate> cachedView = [self.mediaViews objectForKey:existingAttachmentID];
    //
    //        if ([view isEqual:cachedView]) {
    //            [keysToRemove addObject:existingAttachmentID];
    //        }
    //    }
    //
    //    for (NSString* key in keysToRemove) {
    //        [self.mediaViews removeObjectForKey:key];
    //    }
//    //
    if (![self.mediaInteractors objectForKey:attachment.ID]) {
    
        QMMediaPresenter *presenter = [[QMMediaPresenter alloc] initWithView:view];
        
        [view setPresenter:presenter];
        
        QMMediaInteractor *interactor = [[QMMediaInteractor alloc] init];
        interactor.mediaID = attachment.ID;
    
     //    interactor.message = message;
          presenter.interactor = interactor;
          interactor.output = presenter;
        
        interactor.playerService = self;
    
    
    self.mediaInteractors[attachment.ID] = interactor;
        
        [[QMCore instance].chatService.chatAttachmentService.mediaService mediaForMessage:message
                                                                      withCompletionBlock:^(QMMediaItem *mediaItem, NSError *error) {
                                                                          
                                                                
                                                                          QMMediaInteractor *interactor = self.mediaInteractors[mediaItem.mediaID];
                                                                          
                                                                          if (error != nil) {
                                                                              if (self.onError) {
                                                                                  self.onError(message,error);
                                                                              }
                                                                          }
                                                                          else if (mediaItem != nil) {
                                                                              
                                                                              mediaItem.isReady = YES;
                                                                              [interactor updateWithMedia:mediaItem];
                                                                          }
                                                                      }];
    }
}

- (void)unbindViewWithMessage:(QBChatMessage *)message {
    
    id<QMMediaViewDelegate> view = [self.mediaViews objectForKey:message.ID];
    NSString *mediaID = [[[view presenter] interactor] mediaID];
    if (mediaID) {
        [self.mediaInteractors removeObjectForKey:mediaID];
    }
    [[view presenter] setInteractor:nil];
    
    [self.mediaInteractors removeObjectForKey:message.ID];
}

//MARK: - QMChatAttachmentService Delegate
- (void)chatAttachmentService:(QMChatAttachmentService *__unused)chatAttachmentService
    didChangeAttachmentStatus:(QMMessageAttachmentStatus)status
                   forMessage:(QBChatMessage *)message {
    
    if (self.onMessageStatusDidChange) {
        self.onMessageStatusDidChange(status, message);
    }
}

- (void)chatAttachmentService:(QMChatAttachmentService *)__unused chatAttachmentService didChangeLoadingProgress:(CGFloat)progress forMessage:(QBChatMessage *)message attachment:(QBChatAttachment *)attachment {
    NSLog(@"didChangeLoadingProgress for atta id: %@ progress %f.",attachment.ID, progress*100);
    
    QMMediaInteractor *interactor = self.mediaInteractors[attachment.ID];
    [interactor.output didUpdateProgress:progress];
}

- (void)chatAttachmentService:(QMChatAttachmentService *)__unused chatAttachmentService
   didChangeUploadingProgress:(CGFloat)progress
                   forMessage:(QBChatMessage *)message {
    
    id <QMMediaViewDelegate> view = [self.mediaViews objectForKey:message.ID];
    
    if (view == nil && progress < 1.0f) {
        
        if (self.viewForMessage)
        {
            view = self.viewForMessage(message);
            if (view) {
                [self.mediaViews setObject:view forKey:message.ID];
            }
        }
    }
    [view presenter];
}

- (void)activateMedia:(QMMediaItem *)mediaItem sender:(QMMediaInteractor *)sender {
    
    [[QMAudioPlayer audioPlayer] activateMedia:mediaItem];
    self.audioInteractors[mediaItem.mediaID] = sender;
}

- (void)player:(QMAudioPlayer *__unused)player didChangePlayingStatus:(QMAudioPlayerStatus *)status {
    
    NSString *mediaID = status.mediaID;
    
    QMMediaInteractor * interactor = self.audioInteractors[mediaID];
    [interactor.output didUpdateCurrentTime:status.currentTime duration:status.duration];
}

- (void)activateMediaForMessage:(QBChatMessage *)message {
    NSLog(@"message activate = ID = %@",message.ID);
}

@end
