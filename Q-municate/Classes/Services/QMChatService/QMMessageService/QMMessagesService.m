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
                                 @"date_sent" : @((NSUInteger)[[NSDate date] timeIntervalSince1970]),
                                 @"save_to_history" : @YES
                                 }.mutableCopy;
    
    BOOL success = [[QBChat instance] sendChatMessage:message toRoom:chatRoom];
    
    return success;
}

- (void)messageWithDialogID:(NSString *)dialogID completion:(QBChatHistoryMessageResultBlock)completion {
    
	[QBChat messagesWithDialogID:dialogID delegate:[QBEchoObject instance] context:[QBEchoObject makeBlockForEchoObject:completion]];
}

@end
