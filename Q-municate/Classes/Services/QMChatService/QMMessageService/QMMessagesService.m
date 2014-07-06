//
//  QMMessagesService.m
//  Qmunicate
//
//  Created by Andrey on 02.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMMessagesService.h"
#import "QBEchoObject.h"

@implementation QMMessagesService

/**
 didNotSendMessage fired when message cannot be send to user
 
 @param message Message passed to sendMessage method into QBChat
 */
- (void)chatDidNotSendMessage:(QBChatMessage *)message {
    
}

/**
 didReceiveMessage fired when new message was received from QBChat
 
 @param message Message received from Chat
 */
- (void)chatDidReceiveMessage:(QBChatMessage *)message {
    
}

- (BOOL)sendMessage:(QBChatMessage *)message saveToHistory:(BOOL)save {
    
    message.customParameters = @{
                                 @"date_sent" : @([[NSDate date] timeIntervalSince1970]),
                                 @"save_to_history" : @(save)
                                 }.mutableCopy;
    
    BOOL success  = [[QBChat instance] sendMessage:message];
    
    return success;
}

- (BOOL)sendChatMessage:(QBChatMessage *)message toRoom:(QBChatRoom *)chatRoom {
    // additional params:
    message.customParameters = @{
                                 @"date_sent" : @([[NSDate date] timeIntervalSince1970]),
                                 @"save_to_history" : @YES
                                 }.mutableCopy;
    
    BOOL success = [[QBChat instance] sendChatMessage:message toRoom:chatRoom];
    
    return success;
}

- (void)getMessageHistoryWithDialogID:(NSString *)dialogIDString withCompletion:(QBChatHistoryMessageResultBlock)completion {
    
	[QBChat messagesWithDialogID:dialogIDString delegate:[QBEchoObject instance] context:[QBEchoObject makeBlockForEchoObject:completion]];
}

@end
