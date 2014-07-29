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

@interface QMMessagesService()

@property (strong, nonatomic) NSMutableDictionary *history;

@end

@implementation QMMessagesService

- (void)start {
    
    self.history = [NSMutableDictionary dictionary];

    __weak __typeof(self)weakSelf = self;
    void (^updateHistory)(QBChatMessage *) = ^(QBChatMessage *message) {

        if (message.recipientID != message.senderID) {
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

- (void)destroy {
    
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

- (BOOL)sendMessage:(QBChatMessage *)message withDialogID:(NSString *)dialogID saveToHistory:(BOOL)save {
    
    message.cParamDialogID = dialogID;
     message.cParamDateSent = @((NSInteger)CFAbsoluteTimeGetCurrent() + kCFAbsoluteTimeIntervalSince1970);
    if (save) {
        message.cParamSaveToHistory = @"1";
    }
    
    BOOL success  = [[QBChat instance] sendMessage:message];
    
    return success;
}

- (BOOL)sendChatMessage:(QBChatMessage *)message withDialogID:(NSString *)dialogID toRoom:(QBChatRoom *)chatRoom {
    
    message.cParamDialogID = dialogID;
    message.cParamSaveToHistory = @"1";
    message.cParamDateSent = @((NSInteger)CFAbsoluteTimeGetCurrent() + kCFAbsoluteTimeIntervalSince1970);
    
    BOOL success = [[QBChat instance] sendChatMessage:message toRoom:chatRoom];
    
    return success;
}

- (void)messagesWithDialogID:(NSString *)dialogID completion:(QBChatHistoryMessageResultBlock)completion {
    
    __weak __typeof(self)weakSelf = self;
    QBChatHistoryMessageResultBlock echoObject = ^(QBChatHistoryMessageResult *result) {
        [weakSelf setMessages:result.messages.count ? result.messages.mutableCopy : @[].mutableCopy withDialogID:dialogID];
        completion(result);
    };
    
	[QBChat messagesWithDialogID:dialogID delegate:[QBEchoObject instance] context:[QBEchoObject makeBlockForEchoObject:echoObject]];
}

@end
