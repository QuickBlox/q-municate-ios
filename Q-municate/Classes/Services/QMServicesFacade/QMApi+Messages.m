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
#import "QMSettingsManager.h"
#import "QMChatReceiver.h"

@implementation QMApi (Messages)

- (void)loginChat:(QBChatResultBlock)block {
    [self.messagesService loginChat:^(BOOL success) {
        block(success);
    }];
}

- (void)logoutFromChat {
    [self.messagesService logoutChat];
    [self.settingsManager setLastActivityDate:[NSDate date]];
}

- (void)fetchMessageWithDialog:(QBChatDialog *)chatDialog complete:(void(^)(BOOL success))complete {
    
    __weak __typeof(self)weakSelf = self;
    [self.messagesService messagesWithDialogID:chatDialog.ID completion:^(QBChatHistoryMessageResult *result) {
        complete ([weakSelf checkResult:result]); 
    }];
}

- (void)fetchMessagesForActiveChatIfNeededWithCompletion:(void(^)(BOOL fetchWasNeeded))block
{
    if (self.settingsManager.dialogWithIDisActive) {
        [self.messagesService messagesWithDialogID:self.settingsManager.dialogWithIDisActive completion:^(QBChatHistoryMessageResult *result) {
            [[QMChatReceiver instance] messageHistoryWasUpdated];
            if (block) block(YES);
        }];
        return;
    }
    if (block) block(NO);
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
        
        [self.messagesService sendGroupChatMessage:message toDialog:dialog completion:^(NSError *error){
            if (!error) {
                finish(message);
            }
        }];
        
    } else if (dialog.type == QBChatDialogTypePrivate) {
        
        message.senderID = self.currentUser.ID;
        message.recipientID = [self occupantIDForPrivateChatDialog:dialog];
        [self.messagesService sendPrivateMessage:message toDialog:dialog persistent:YES completion:^(NSError *error) {
            finish(message);
        }];
    }
}

- (void)sendText:(NSString *)text toDialog:(QBChatDialog *)dialog completion:(void(^)(QBChatMessage * message))completion {
    
    QBChatMessage *message = [[QBChatMessage alloc] init];
    message.text = text;
    [self sendMessage:message toDialog:dialog completion:completion];
}

- (void)sendAttachment:(QBCBlob *)attachment toDialog:(QBChatDialog *)dialog completion:(void(^)(QBChatMessage * message))completion {
    
    QBChatMessage *message = [[QBChatMessage alloc] init];
    message.text = @"Attachment";
    QBChatAttachment *attach = [[QBChatAttachment alloc] init];
    attach.url = attachment.publicUrl;
    attach.type = @"image";
    attach.name = attachment.name;
    attach.contentType = attachment.contentType;
    attach.size = attachment.size;
    message.attachments = @[attach];
    
    [self sendMessage:message toDialog:dialog completion:completion];
}

- (NSArray *)messagesHistoryWithDialog:(QBChatDialog *)chatDialog {
    return [self.messagesService messageHistoryWithDialogID:chatDialog.ID];
}


#pragma mark - Setter & Getter

- (void)setPushNotification:(NSDictionary *)pushNotification
{
    [self.messagesService setPushNotification:pushNotification];
}

- (NSDictionary *)pushNotification
{
    return self.messagesService.pushNotification;
}

@end
