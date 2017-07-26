//
//  QMBaseMediaCell+QMMediaController.m
//  Q-municate
//
//  Created by Vitaliy Gurkovsky on 7/17/17.
//  Copyright © 2017 Quickblox. All rights reserved.
//

#import "QMBaseMediaCell+QMMediaController.h"
#import "QMCore.h"
#import "QMServices.h"
#import "QMChatResources.h"

@implementation QMBaseMediaCell (QMMediaController)

- (void)updateWithAttachment:(QBChatAttachment *)attachment
                   messageID:(NSString *)messageID
                    dialogID:(NSString *)dialopgID {
    
    QBChatMessage *message = [QMCore.instance.chatService.messagesMemoryStorage messageWithID:messageID fromDialogID:dialopgID];
    
    NSString *status = [[self attachmentsService] statusForMessage:message];
    
    if (![self.messageID isEqualToString:messageID] && self.messageID != nil) {
        
        if (status != QMAttachmentStatus.uploading || status != QMAttachmentStatus.downloading) {
            [self.mediaHandler shouldCancelOperation:self];
        }
    }
    
    self.messageID = messageID;
    
    [self updateViewForStatus:status];
}

- (void)updateViewForStatus:(NSString *)attStatus {
    
    if (attStatus == QMAttachmentStatus.notLoaded) {
        self.isReady = NO;
        self.isLoading = NO;
        self.progress = 0;
        self.viewState = QMMediaViewStateNotReady;
    }
    else if (attStatus == QMAttachmentStatus.downloading || attStatus == QMAttachmentStatus.uploading) {
        self.viewState = QMMediaViewStateLoading;
        self.isReady = NO;
        self.isLoading = YES;
        self.progress = [QMCore.instance.chatService.chatAttachmentService.webService progressForMessageWithID:self.messageID];
    }
    
    else if (attStatus == QMAttachmentStatus.preparing) {
        self.viewState = QMMediaViewStateLoading;
        self.isReady = NO;
        self.isLoading = YES;
    }
    else if (attStatus == QMAttachmentStatus.prepared) {
        self.viewState = QMMediaViewStateReady;
        self.isReady = YES;
        self.isLoading = NO;
    }
    else if (attStatus == QMAttachmentStatus.loaded) {
        self.viewState = QMMediaViewStateReady;
        self.isReady = YES;
        self.isLoading = NO;
    }
    
    UIImage *buttonImage = QMPlayButtonImageForStatus(self.viewState);
    NSTimeInterval animationDuration = self.viewState == QMMediaViewStateActive ? 0.15 : 0.0;
    [UIView transitionWithView:self.mediaPlayButton
                      duration:animationDuration
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        [self.mediaPlayButton setImage:buttonImage
                                              forState:UIControlStateNormal];
                        [self.mediaPlayButton setImage:buttonImage
                                              forState:UIControlStateDisabled];
                    } completion:nil];
}



- (QMChatAttachmentService *)attachmentsService {
    
    return QMCore.instance.chatService.chatAttachmentService;
}


static inline UIImage *QMPlayButtonImageForStatus(QMMediaViewState state) {
    
    NSString *imageName;
    
    switch (state) {
        case QMMediaViewStateNotReady: imageName = @"download_icon"; break;
        case QMMediaViewStateReady:    imageName  = @"play_icon"; break;
        case QMMediaViewStateLoading:  imageName = @"cancel_icon"; break;
        case QMMediaViewStateActive:   imageName = @"pause_icon"; break;
    }
    
    return [QMChatResources imageNamed:imageName];
}
@end
