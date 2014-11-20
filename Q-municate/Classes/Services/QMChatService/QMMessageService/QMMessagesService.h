//
//  QMMessagesService.h
//  Qmunicate
//
//  Created by Andrey Ivanov on 02.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QMOldBaseService.h"

@interface QMMessagesService : QMOldBaseService

@property (strong, nonatomic) NSDictionary *pushNotification;
@property (strong, nonatomic) QBUUser *currentUser;
@property (strong, nonatomic) NSMutableDictionary *enqueuedMessages;

- (void)chat:(void(^)(QBChat *chat))chatBlock;
- (void)loginChat:(QBChatResultBlock)block;
- (void)logoutChat;

- (NSArray *)messageHistoryWithDialogID:(NSString *)dialogID;
- (void)addMessageToHistory:(QBChatMessage *)message withDialogID:(NSString *)dialogID;
- (void)deleteMessageHistoryWithChatDialogID:(NSString *)dialogID;

/**
 Send message
 
 @param message QBChatMessage structure which contains message text and recipient id
 @return YES if the request was sent successfully. If not - see log.
 */
- (void)sendPrivateMessage:(QBChatMessage *)message toDialog:(QBChatDialog *)dialog persistent:(BOOL)persistent completion:(void(^)(NSError *error))completion;

/**
 Send chat message to room
 
 @param message Message body
 @param room Room to send message
 @return YES if the request was sent successfully. If not - see log.
 */
- (void)sendGroupChatMessage:(QBChatMessage *)message toDialog:(QBChatDialog *)dialog completion:(void(^)(NSError *))completion;

/**
 *
 */
- (void)messagesWithDialogID:(NSString *)dialogID completion:(QBChatHistoryMessageResultBlock)completion;

@end
