//
//  QMMediaController.h
//  Q-municate
//
//  Created by Vitaliy Gurkovsky on 2/19/17.
//  Copyright © 2017 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "QMMediaViewDelegate.h"
#import "QMMediaPresenter.h"

@protocol QMChatAttachmentCell;

@interface QMMediaController : NSObject <QMChatAttachmentServiceDelegate>

@property (copy, nonatomic) void(^onMessageStatusDidChange)(QMMessageAttachmentStatus status, QBChatMessage *message);
@property (copy, nonatomic) void(^onError)(QBChatMessage *message, NSError *error);

@property (copy, nonatomic) id<QMMediaViewDelegate>(^viewForMessage)(QBChatMessage *message);



- (void)bindAttachmentCell:(UIView<QMChatAttachmentCell> *)cell withMessage:(QBChatMessage *)message;
- (void)unbindAttachmentCellForMessage:(QBChatMessage *)message;

- (id<QMMediaViewDelegate>)bindView:(id<QMMediaViewDelegate>)view withMessage:(QBChatMessage *)message attachmentID:(NSString *)attachmentID;
- (void)unbindViewWithAttachment:(QBChatAttachment *)attachment;

@end
