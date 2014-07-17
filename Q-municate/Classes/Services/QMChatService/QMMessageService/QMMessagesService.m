//
//  QMMessagesService.m
//  Qmunicate
//
//  Created by Andrey on 02.07.14.
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

        NSString *dialogIDKey = @"dialog_id";
        NSString *dialogID = message.customParameters[dialogIDKey];
        [weakSelf addMessageInHistory:message withDialogID:dialogID];
    };
    
    [[QMChatReceiver instance] chatDidReceiveMessageWithTarget:self block:^(QBChatMessage *message) {
        updateHistory(message);
    }];
    
    [[QMChatReceiver instance] chatRoomDidReceiveMessageWithTarget:self block:^(QBChatMessage *message, NSString *roomJID) {
        updateHistory(message);
    }];
}

- (void)destroy {
    
    [self.history removeAllObjects];
}

- (void)setMessages:(NSArray *)messages withDialogID:(NSString *)dialogID {
    
    self.history[dialogID] = messages;
}

- (void)addMessageInHistory:(QBChatMessage *)message withDialogID:(NSString *)dialogID {
    
    NSMutableArray *history = self.history[dialogID];
    NSInteger idx = [history indexOfObject:message];

    if (idx != NSNotFound) {
        [history replaceObjectAtIndex:idx withObject:message];
    }else {
        [history addObject:message];
    }
}

- (NSArray *)messageHistoryWithDialogID:(NSString *)dialogID {
    
    NSArray *messages = self.history[dialogID];
    return messages;
}

- (BOOL)sendMessage:(QBChatMessage *)message withDialogID:(NSString *)dialogID saveToHistory:(BOOL)save {
    
    message.customParameters = [self messageCusotmParameterWithDialogID:dialogID saveToHistory:save];
    BOOL success  = [[QBChat instance] sendMessage:message];
    
    return success;
}

- (BOOL)sendChatMessage:(QBChatMessage *)message withDialogID:(NSString *)dialogID toRoom:(QBChatRoom *)chatRoom {
    
    message.customParameters = [self messageCusotmParameterWithDialogID:dialogID saveToHistory:YES];
    BOOL success = [[QBChat instance] sendChatMessage:message toRoom:chatRoom];
    
    return success;
}

- (NSMutableDictionary *)messageCusotmParameterWithDialogID:(NSString *)dialogID saveToHistory:(BOOL)saveToHistory {
    return @{
             @"date_sent" : @((NSUInteger)[[NSDate date] timeIntervalSince1970]),
             @"save_to_history" : @(saveToHistory),
             @"dialog_id" : dialogID
             }.mutableCopy;
}

- (void)messagesWithDialogID:(NSString *)dialogID completion:(QBChatHistoryMessageResultBlock)completion {
    
    QBChatHistoryMessageResultBlock echoObject = ^(QBChatHistoryMessageResult *result) {
        [self setMessages:result.messages.count ? result.messages.mutableCopy : @[].mutableCopy withDialogID:dialogID];
        completion(result);
    };
    
	[QBChat messagesWithDialogID:dialogID delegate:[QBEchoObject instance] context:[QBEchoObject makeBlockForEchoObject:echoObject]];
}

@end
