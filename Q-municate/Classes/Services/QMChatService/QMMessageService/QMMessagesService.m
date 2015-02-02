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
    self.messageDeliveryBlockList = [NSMutableDictionary dictionary];
}

- (void)stop {
    [super stop];
    
    [[QMChatReceiver instance] unsubscribeForTarget:self];
    self.history = nil;
    self.messageDeliveryBlockList = nil;
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

- (void)deleteMessageHistoryWithChatDialogID:(NSString *)dialogID
{
    self.history[dialogID] = @[].mutableCopy;
}

- (void)sendPrivateMessage:(QBChatMessage *)message toDialog:(QBChatDialog *)dialog persistent:(BOOL)persistent completion:(void(^)(NSError *error))completion {
    
    message.cParamDialogID = dialog.ID;
    message.cParamDateSent = @((NSInteger)CFAbsoluteTimeGetCurrent() + kCFAbsoluteTimeIntervalSince1970);
    message.text = [message.text gtm_stringByEscapingForHTML];
    
    if (persistent) {
        message.cParamSaveToHistory = @"1";
        message.markable = YES;
    }
    
    [self chat:^(QBChat *chat) {
       if ( [chat sendMessage:message]) {
          if (completion) completion(nil);
       };
    }];
}

- (void)sendGroupChatMessage:(QBChatMessage *)message toDialog:(QBChatDialog *)dialog completion:(void(^)(NSError *))completion {
    
    message.cParamDialogID = dialog.ID;
    message.cParamSaveToHistory = @"1";
    message.cParamDateSent = @((NSInteger)CFAbsoluteTimeGetCurrent() + kCFAbsoluteTimeIntervalSince1970);
    message.text = [message.text gtm_stringByEscapingForHTML];
    QBChatRoom *chatRoom = dialog.chatRoom;
    
    if (!chatRoom.isJoined) {
        if (completion) completion([NSError errorWithDomain:@"Error. Room is not joined" code:0 userInfo:nil]);
        return;
    }
    __weak typeof(self)weakSelf = self;
    [self chat:^(QBChat *chat) {
        if ([chat sendChatMessage:message toRoom:chatRoom]) {
            if (message.cParamNotificationType == QMMessageNotificationTypeCreateGroupDialog) {
               if (completion) weakSelf.messageDeliveryBlockList[chatRoom.JID] = completion;
            } else {
                if (completion) completion(nil);
            }
        }
    }];
}

- (void)messagesWithDialogID:(NSString *)dialogID completion:(QBChatHistoryMessageResultBlock)completion {
    
    __weak __typeof(self)weakSelf = self;
    QBChatHistoryMessageResultBlock echoObject = ^(QBChatHistoryMessageResult *result) {
        NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"datetime" ascending:YES];
        NSMutableArray *messages = result.messages.count ? result.messages.mutableCopy : @[].mutableCopy;
        [messages sortUsingDescriptors:@[descriptor]];
        [weakSelf setMessages:messages withDialogID:dialogID];
        completion(result);
    };
    
    NSMutableDictionary *extendedRequest = @{@"sort_desc": @"date_sent"}.mutableCopy;
    
    [QBChat messagesWithDialogID:dialogID extendedRequest:extendedRequest delegate:[QBEchoObject instance] context:[QBEchoObject makeBlockForEchoObject:echoObject]];
    
//    QBResponsePage *page = [QBResponsePage responsePageWithLimit:50];
//    
//    [QBRequest messagesWithDialogID:dialogID extendedRequest:extendedRequest forPage:page successBlock:^(QBResponse *responce, NSArray *dialogs, QBResponsePage *responcePage) {
//        //
//    } errorBlock:^(QBResponse *response) {
//        //
//    }];
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
