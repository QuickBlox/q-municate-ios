//
//  QMApi+Messages.m
//  Qmunicate
//
//  Created by Andrey Ivanov on 03.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMApi.h"
#import "QMMessagesService.h"

@implementation QMApi (Messages)

- (void)fetchMessageWithDialog:(QBChatDialog *)chatDialog complete:(void(^)(BOOL success))complete {
    
    __weak __typeof(self)weakSelf = self;
    [self.messagesService messagesWithDialogID:chatDialog.ID completion:^(QBChatHistoryMessageResult *result) {
        complete ([weakSelf checkResult:result]);
    }];
}

- (QBChatMessage *)sendMessage:(QBChatMessage *)message toDialog:(QBChatDialog *)dialog {
    
    BOOL success = NO;
    
    if (dialog.type == QBChatDialogTypeGroup) {
        
        QBChatRoom *room = [self chatRoomWithRoomJID:dialog.roomJID];
        success = [self.messagesService sendChatMessage:message withDialogID:dialog.ID toRoom:room];
        
    } else if (dialog.type == QBChatDialogTypePrivate) {
        
        message.senderID = self.currentUser.ID;
        message.recipientID = [self occupantIDForPrivateChatDialog:dialog];
        success = [self.messagesService sendMessage:message  withDialogID:dialog.ID saveToHistory:YES];
    }
    
    if (success) {
        
        message.senderID = self.currentUser.ID;
        [self.messagesService addMessageToHistory:message withDialogID:dialog.ID];
        dialog.lastMessageText = message.text;
        dialog.lastMessageDate = message.datetime;

        return message;
    }
    
    return nil;
}

- (QBChatMessage *)sendText:(NSString *)text toDialog:(QBChatDialog *)dialog {
    
    QBChatMessage *message = [[QBChatMessage alloc] init];
    message.text = text;
    return [self sendMessage:message toDialog:dialog];
}

- (QBChatMessage *)sendAttachment:(NSString *)attachmentUrl toDialog:(QBChatDialog *)dialog {
    
    QBChatMessage *message = [[QBChatMessage alloc] init];
    
    QBChatAttachment *attachment = [[QBChatAttachment alloc] init];
    attachment.url = attachmentUrl;
    attachment.type = @"image";
    
    message.attachments = @[attachment];
    
    return [self sendMessage:message toDialog:dialog];
}

- (NSArray *)messagesHistoryWithDialog:(QBChatDialog *)chatDialog {
    return [self.messagesService messageHistoryWithDialogID:chatDialog.ID];
}

@end
