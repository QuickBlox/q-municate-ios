//
//  QMMessagesService.m
//  Qmunicate
//
//  Created by Andrey Ivanov on 02.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMMessagesService.h"
#import "QBEchoObject.h"
#import "QMChatReceiver.h"
#import "NSString+GTMNSStringHTMLAdditions.h"

@interface QMMessagesService()

@property (strong, nonatomic) NSMutableDictionary *history;

@end

@implementation QMMessagesService

- (void)chat:(void(^)(QBChat *chat))chatBlock {
    
    if ([[QBChat instance] isLoggedIn]) {
        chatBlock([QBChat instance]);
    }
    else {
        [self loginChat:^(BOOL success) {
            chatBlock([QBChat instance]);
        }];
    }
}

- (void)loginChat:(QBChatResultBlock)block {
    
    if (!self.currentUser) {
        block(NO);
        return;
    }
    
    if (([[QBChat instance] isLoggedIn])) {
        block(YES);
        return;
    }
    
    [[QMChatReceiver instance] chatDidLoginWithTarget:self block:block];
    [[QMChatReceiver instance] chatDidNotLoginWithTarget:self block:block];

    NSAssert(self.currentUser, @"update this case");
    [[QBChat instance] loginWithUser:self.currentUser];
}

- (void)logoutChat {
    
    if ([[QBChat instance] isLoggedIn]) {
        [[QBChat instance] logout];
        [[QMChatReceiver instance] unsubscribeForTarget:self];
    }
}

- (void)start {
    [super start];
    
    self.history = [NSMutableDictionary dictionary];

    __weak __typeof(self)weakSelf = self;
    void (^updateHistory)(QBChatMessage *) = ^(QBChatMessage *message) {

        if (message.recipientID != message.senderID && message.cParamNotificationType == QMMessageNotificationTypeNone) {
            [weakSelf addMessageToHistory:message withDialogID:message.cParamDialogID];
        }
    };
    
    [[QMChatReceiver instance] chatDidReceiveMessageWithTarget:self block:^(QBChatMessage *message) {
        updateHistory(message);
    }];
    
    [[QMChatReceiver instance] chatRoomDidReceiveMessageWithTarget:self block:^(QBChatMessage *message, NSString *roomJID) {
        updateHistory(message);
    }];
}

- (void)stop {
    [super stop];
    
    [[QMChatReceiver instance] unsubscribeForTarget:self];
    [self.history removeAllObjects];
}

- (void)setMessages:(NSArray *)messages withDialogID:(NSString *)dialogID {
    
    self.history[dialogID] = messages;
}

- (void)addMessageToHistory:(QBChatMessage *)message withDialogID:(NSString *)dialogID {
    
    NSMutableArray *history = self.history[dialogID];
    [history addObject:message];
}

- (NSArray *)messageHistoryWithDialogID:(NSString *)dialogID {
    
    NSArray *messages = self.history[dialogID];
    return messages;
}

- (void)sendMessage:(QBChatMessage *)message withDialogID:(NSString *)dialogID saveToHistory:(BOOL)save completion:(void(^)(NSError *error))completion {
    
    message.cParamDialogID = dialogID;
    message.cParamDateSent = @((NSInteger)CFAbsoluteTimeGetCurrent() + kCFAbsoluteTimeIntervalSince1970);
    message.text = [message.text gtm_stringByEscapingForHTML];
    
    if (save) {
        message.cParamSaveToHistory = @"1";
        message.markable = YES;
    }
    
    [self chat:^(QBChat *chat) {
        [chat sendMessage:message sentBlock:^(NSError *error) {
            completion(error);
        }];
    }];
}

- (void)sendChatMessage:(QBChatMessage *)message withDialogID:(NSString *)dialogID toRoom:(QBChatRoom *)chatRoom completion:(void(^)(void))completion {
    
    message.cParamDialogID = dialogID;
    message.cParamSaveToHistory = @"1";
    message.cParamDateSent = @((NSInteger)CFAbsoluteTimeGetCurrent() + kCFAbsoluteTimeIntervalSince1970);
    message.text = [message.text gtm_stringByEscapingForHTML];
    
    [self chat:^(QBChat *chat) {
        if ([chat sendChatMessage:message toRoom:chatRoom]) {
            completion();
        }
    }];
}

- (void)messagesWithDialogID:(NSString *)dialogID completion:(QBChatHistoryMessageResultBlock)completion {
    
    __weak __typeof(self)weakSelf = self;
    QBChatHistoryMessageResultBlock echoObject = ^(QBChatHistoryMessageResult *result) {
        [weakSelf setMessages:result.messages.count ? result.messages.mutableCopy : @[].mutableCopy withDialogID:dialogID];
        completion(result);
    };
    
    [QBChat messagesWithDialogID:dialogID delegate:[QBEchoObject instance] context:[QBEchoObject makeBlockForEchoObject:echoObject]];
}

- (void)messagesWithDialogID:(NSString *)dialogID time:(NSUInteger)time completion:(QBChatHistoryMessageResultBlock)completion {
    
    __weak __typeof(self)weakSelf = self;
    QBChatHistoryMessageResultBlock echoObject = ^(QBChatHistoryMessageResult *result) {
        [weakSelf setMessages:result.messages.count ? result.messages.mutableCopy : @[].mutableCopy withDialogID:dialogID];
        completion(result);
    };
    
    NSMutableDictionary *getRequest = [NSMutableDictionary dictionary];
    
    [getRequest setObject:@(time)
                   forKey:@"date_send[gt]"];
    
    [QBChat messagesWithDialogID:dialogID extendedRequest:getRequest delegate:[QBEchoObject instance] context:[QBEchoObject makeBlockForEchoObject:echoObject]];
}

@end
