//
//  QMApi+Messages.m
//  Qmunicate
//
//  Created by Andrey on 03.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMApi.h"
#import "QMMessagesService.h"

@interface QMApi()

@property (strong, nonatomic) NSMutableDictionary *messages;

@end

@implementation QMApi (Messages)

- (void)fetchMessageWithDialog:(QBChatDialog *)chatDialog complete:(void(^)(BOOL success))complete {
    
    [self.messagesService messageWithDialogID:chatDialog.ID completion:^(QBChatHistoryMessageResult *result) {
        if ([self checkResult:result]) {
            [self addMessages:result.messages ? result.messages : @[] withDialog:chatDialog];
        }
        complete (result.success);
    }];
}

- (void)addMessages:(NSArray *)messages withDialog:(QBChatDialog *)dialog {
    
    self.messages[dialog.ID] = messages;
}

- (NSArray *)messagesWithDialog:(QBChatDialog *)chatDialog {

    NSArray *messages = self.messages[chatDialog.ID];
    return messages;
}

- (void)sendText:(NSString *)text toDialog:(QBChatDialog *)dialog {
    
    QBChatMessage *message = [QBChatMessage message];
    message.senderID = self.currentUser.ID;
    message.text = text;

    if (dialog.type == QBChatDialogTypeGroup) {

        QBChatRoom *room = [self roomWithRoomJID:dialog.roomJID];
        [self.messagesService sendChatMessage:message toRoom:room];
    }
}

@end
