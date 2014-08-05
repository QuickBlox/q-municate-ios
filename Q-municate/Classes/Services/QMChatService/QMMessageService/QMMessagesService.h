//
//  QMMessagesService.h
//  Qmunicate
//
//  Created by Andrey Ivanov on 02.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QMBaseService.h"

@interface QMMessagesService : QMBaseService

- (NSArray *)messageHistoryWithDialogID:(NSString *)dialogID;
- (void)addMessageToHistory:(QBChatMessage *)message withDialogID:(NSString *)dialogID;

/**
 Send message
 
 @param message QBChatMessage structure which contains message text and recipient id
 @return YES if the request was sent successfully. If not - see log.
 */
- (BOOL)sendMessage:(QBChatMessage *)message withDialogID:(NSString *)dialogID saveToHistory:(BOOL)save;

/**
 Send chat message to room
 
 @param message Message body
 @param room Room to send message
 @return YES if the request was sent successfully. If not - see log.
 */
- (BOOL)sendChatMessage:(QBChatMessage *)message withDialogID:(NSString *)dialogID toRoom:(QBChatRoom *)chatRoom;

- (void)messagesWithDialogID:(NSString *)dialogID completion:(QBChatHistoryMessageResultBlock)completion;

@end
