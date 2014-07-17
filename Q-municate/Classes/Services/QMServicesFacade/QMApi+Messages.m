//
//  QMApi+Messages.m
//  Qmunicate
//
//  Created by Andrey on 03.07.14.
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

- (BOOL)sendText:(NSString *)text toDialog:(QBChatDialog *)dialog {
    
    QBChatMessage *message = [[QBChatMessage alloc] init];
    
    message.text = text;
    
    BOOL success = NO;
    
    if (dialog.type == QBChatDialogTypeGroup) {
        QBChatRoom *room = [self roomWithRoomJID:dialog.roomJID];
        success = [self.messagesService sendChatMessage:message withDialogID:dialog.ID toRoom:room];
        
    } else if (dialog.type == QBChatDialogTypePrivate) {
        message.senderID = self.currentUser.ID;
        message.recipientID = [self occupantIDForPrivateChatDialog:dialog].integerValue;
        success = [self.messagesService sendMessage:message  withDialogID:dialog.ID saveToHistory:YES];
    }
    
    if (success) {
        [self.messagesService addMessageInHistory:message withDialogID:dialog.ID];
        dialog.lastMessageText = message.text;
        dialog.lastMessageDate = message.datetime;
    }
    
    return success;
}

- (NSArray *)messagesHistoryWithDialog:(QBChatDialog *)chatDialog {
    return [self.messagesService messageHistoryWithDialogID:chatDialog.ID];
}

@end
