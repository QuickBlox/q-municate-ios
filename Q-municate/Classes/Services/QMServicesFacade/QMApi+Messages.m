//
//  QMApi+Messages.m
//  Qmunicate
//
//  Created by Andrey Ivanov on 03.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMApi.h"
#import "QMMessagesService.h"
#import "QMChatDialogsService.h"

@implementation QMApi (Messages)

- (void)loginChat:(QBChatResultBlock)block {
    
    __weak __typeof(self)weakSelf = self;
    [self.messagesService loginChat:^(BOOL success) {
        [weakSelf.chatDialogsService joinRooms];
        block(success);
    }];
}

- (void)logoutFromChat {
    [self.chatDialogsService leaveFromRooms];
    [self.messagesService logoutChat];
}

- (void)fetchMessageWithDialog:(QBChatDialog *)chatDialog complete:(void(^)(BOOL success))complete {
    
    __weak __typeof(self)weakSelf = self;
    [self.messagesService messagesWithDialogID:chatDialog.ID completion:^(QBChatHistoryMessageResult *result) {
        complete ([weakSelf checkResult:result]);
    }];
}

- (void)sendMessage:(QBChatMessage *)message toDialog:(QBChatDialog *)dialog completion:(void(^)(QBChatMessage * message))completion {
    
    __weak __typeof(self)weakSelf = self;
    
    void (^finish)(QBChatMessage *) = ^(QBChatMessage *historyMessage){
        
        historyMessage.senderID = weakSelf.currentUser.ID;
        [weakSelf.messagesService addMessageToHistory:historyMessage withDialogID:dialog.ID];
        dialog.lastMessageText = historyMessage.encodedText;
        dialog.lastMessageDate = historyMessage.datetime;
        
        completion(message);
    };
    
    if (dialog.type == QBChatDialogTypeGroup) {
        
        QBChatRoom *chatRoom = [self.chatDialogsService chatRoomWithRoomJID:dialog.roomJID];
        [self.messagesService sendChatMessage:message withDialogID:dialog.ID toRoom:chatRoom completion:^{
            finish(message);
        }];
        
    } else if (dialog.type == QBChatDialogTypePrivate) {
        
        message.senderID = self.currentUser.ID;
        message.recipientID = [self occupantIDForPrivateChatDialog:dialog];
        [self.messagesService sendMessage:message  withDialogID:dialog.ID saveToHistory:YES completion:^{
            finish(message);
        }];
    }
}

- (void)sendText:(NSString *)text toDialog:(QBChatDialog *)dialog completion:(void(^)(QBChatMessage * message))completion {
    
    QBChatMessage *message = [[QBChatMessage alloc] init];
    message.text = text;
    [self sendMessage:message toDialog:dialog completion:completion];
}

- (void)sendAttachment:(NSString *)attachmentUrl toDialog:(QBChatDialog *)dialog completion:(void(^)(QBChatMessage * message))completion {
    
    QBChatMessage *message = [[QBChatMessage alloc] init];
    message.text = @"Attachment";
    QBChatAttachment *attachment = [[QBChatAttachment alloc] init];
    attachment.url = attachmentUrl;
    attachment.type = @"image";
    message.attachments = @[attachment];
    
    [self sendMessage:message toDialog:dialog completion:completion];
}

- (NSArray *)messagesHistoryWithDialog:(QBChatDialog *)chatDialog {
    return [self.messagesService messageHistoryWithDialogID:chatDialog.ID];
}

@end
