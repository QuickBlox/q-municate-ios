 //
//  QMChatService.m
//  Q-municate
//
//  Created by Igor Alefirenko on 17/02/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMChatService.h"
#import "QMUsersService.h"
//#import <TWMessageBarManager.h>
#import "QBEchoObject.h"

@interface QMChatService ()

@property (strong, nonatomic) NSTimer *presenceTimer;
@property (copy, nonatomic) QBChatResultBlock chatLoginBlock;
//@property (copy, nonatomic) QBChatRoomResultBlock chatRoomResultBlock;
//@property (copy, nonatomic) QBChatDialogResultBlock chatDialogResultBlock;
//@property (copy, nonatomic) QBChatDialogHistoryBlock chatDialogHistoryBlock;
//@property (strong, nonatomic) NSTimer *presenceTimer;

///** Upload message needed for replacing with delivered message in chat hisoty. When used, it means that upload finished, and message has been delivered */
//@property (strong, nonatomic) QMChatUploadingMessage *uploadingMessage;

//@property (strong, nonatomic) NSMutableDictionary *allChatRoomsAsDictionary;
//@property (strong, nonatomic) NSMutableDictionary *allConversations;

@end

@implementation QMChatService

- (id)init {
    
    if (self = [super init]) {
        [QBChat instance].delegate = self;
    }
    
    return self;
}

- (BOOL)loginWithUser:(QBUUser *)user completion:(QBChatResultBlock)block {
    self.chatLoginBlock = block;
    return [[QBChat instance] loginWithUser:user];
}

- (BOOL)logout {
    return [[QBChat instance] logout];
}

#pragma mark - STATUS

- (void)sendPresenceWithStatus:(NSString *)status {
    
    if (status) {
        [[QBChat instance] sendPresenceWithStatus:status];
    } else {
        [[QBChat instance] sendPresence];
    }
}

#pragma mark - QMChatService
/**
 didLogin fired by QBChat when connection to service established and login is successfull
 */
- (void)chatDidLogin {
//    if (self.presenceTimer == nil) {
//        self.presenceTimer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(sendPresence) userInfo:nil repeats:YES];
//    }
    self.chatLoginBlock(YES);
}

/**
 didNotLogin fired when login process did not finished successfully
 */
- (void)chatDidNotLogin {
    self.chatLoginBlock(NO);
}

/**
 didFailWithError fired when connection error occurs
 
 @param error Error code from QBChatServiceError enum
 */
- (void)chatDidFailWithError:(NSInteger)code {
    
}

/**
 Called in case receiving presence
 
 @param userID User ID from which received presence
 @param type Presence type
 */
- (void)chatDidReceivePresenceOfUser:(NSUInteger)userID type:(NSString *)type {
    
}

#pragma mark -
#pragma mark Rooms

/**
 Called in case received list of available to join rooms.
 
 @rooms Array of rooms
 */
- (void)chatDidReceiveListOfRooms:(NSArray *)rooms {
    
}
/**
 Called when room receives a message.
 
 @param message Received message
 @param roomJID Room JID
 */
- (void)chatRoomDidReceiveMessage:(QBChatMessage *)message fromRoomJID:(NSString *)roomJID {
    
}

/**
 Called when received room information.
 
 @param information Room information
 @param roomJID JID of room
 @param roomName Name of room
 */
- (void)chatRoomDidReceiveInformation:(NSDictionary *)information roomJID:(NSString *)roomJID roomName:(NSString *)roomName {
    
}

/**
 Fired when room was successfully created
 */
- (void)chatRoomDidCreate:(NSString*)roomName {
    
}

/**
 Fired when you did enter to room
 
 @param room which you have joined
 */
- (void)chatRoomDidEnter:(QBChatRoom *)room {
    
}

/**
 Called when you didn't enter to room
 
 @param room which you haven't joined
 @param error Error
 */
- (void)chatRoomDidNotEnter:(NSString *)roomName error:(NSError *)error{
    
}

/**
 Fired when you did leave room
 
 @param Name of room which you have leaved
 */
- (void)chatRoomDidLeave:(NSString *)roomName {
    
}

/**
 Fired when you did destroy room
 
 @param Name of room which you have destroyed
 */
- (void)chatRoomDidDestroy:(NSString *)roomName {
    
}

/**
 Called in case changing online users
 
 @param onlineUsers Array of online users
 @param roomName Name of room in which have changed online users
 */
- (void)chatRoomDidChangeOnlineUsers:(NSArray *)onlineUsers room:(NSString *)roomName {
    
}

/**
 Called in case receiving list of users who can join room
 
 @param users Array of users which are able to join room
 @param roomName Name of room which provides access to join
 */
- (void)chatRoomDidReceiveListOfUsers:(NSArray *)users room:(NSString *)roomName {
    
}

/**
 Called in case receiving list of active users (joined)
 
 @param users Array of joined users
 @param roomName Name of room
 */
- (void)chatRoomDidReceiveListOfOnlineUsers:(NSArray *)users room:(NSString *)roomName {
    
}



//#pragma mark - QBChatDelegate - Login to Chat



//#pragma mark - Chat
//
//- (void)chatDidReceiveMessage:(QBChatMessage *)message {
//    
//
//}
//
//- (void)chatDidFailWithError:(NSInteger)code {
//	[[NSNotificationCenter defaultCenter] postNotificationName:kChatDidFailWithErrorNotification
//                                                        object:nil
//                                                      userInfo:@{@"errorCode" : @(code)}];
//}
//
//
//- (void)chatRoomDidReceiveMessage:(QBChatMessage *)message fromRoomJID:(NSString *)roomJID
//{
//#warning me.iD
//#warning QMContactList shared
////    if (self.uploadingMessage != nil) {
////        // track all incoming messages with attachments:
////        if ([message.attachments count] > 0) {
////            // if message is mine:
////            if (message.senderID == [QMContactList shared].me.ID) {
////                // get history and replace messages:
////                NSMutableArray *messageHistory = self.allConversations[roomJID];
////                NSUInteger index = [messageHistory indexOfObject:self.uploadingMessage];
////                [messageHistory replaceObjectAtIndex:index withObject:message];
////                [[NSNotificationCenter defaultCenter] postNotificationName:kChatRoomDidReceiveMessageNotification object:nil];
////                
////                // release cached upload message:
////                self.uploadingMessage = nil;
////                return;
////            }
////        }
////    }
//    // if not my message:
//#warning me.iD
//#warning QMContactList shared
//
////    if (message.senderID != [QMContactList shared].me.ID) {
////        // find user:
////        [self searchForOpponentWithIDAndFetchIfNeeded:message.senderID];
////    }
//    
//    [self saveMessageToLocalHistory:message chatDialogKey:roomJID];
//    
//    [[NSNotificationCenter defaultCenter] postNotificationName:kChatRoomDidReceiveMessageNotification object:nil];
//}
//
//- (void)chatRoomDidReceiveInformation:(NSDictionary *)information room:(NSString *)roomName
//{
//    //
//}
//
//- (void)chatRoomDidCreate:(NSString *)roomName {
//    //
//}
//
//- (void)chatRoomDidEnter:(QBChatRoom *)room {
////    [[NSNotificationCenter defaultCenter] postNotificationName:kChatRoomDidEnterNotification object:nil];
//}
//
//- (void)chatRoomDidNotEnter:(NSString *)roomName error:(NSError *)error {
////	if (_chatRoomResultBlock) {
////		[QMChatService shared].chatRoom = nil;
////		_chatRoomResultBlock(nil, error);
////		_chatRoomResultBlock = nil;
////	}
//}
//
//- (void)chatRoomDidLeave:(NSString *)roomName
//{
//	// You leaved room
//}
//
//- (void)chatRoomDidReceiveListOfUsers:(NSArray *)users room:(NSString *)roomName
//{
//    //
//}
//
//- (void)chatRoomDidReceiveListOfOnlineUsers:(NSArray *)users room:(NSString *)roomName
//{
//    [[NSNotificationCenter defaultCenter] postNotificationName:kChatRoomDidChangeOnlineUsersListNotification object:nil userInfo:@{@"online_users":users}];
//}
//
//

//
//#pragma mark - QBActionStatusDelegate
//
//- (void)completedWithResult:(Result *)result
//{
//    if ([result isKindOfClass:[QBChatHistoryMessageResult class]]) {
//        
//        if (result.success) {
//            if (_chatDialogHistoryBlock) {
//                NSMutableArray *messagesMArray = ((QBChatHistoryMessageResult *)result).messages;
//                
//                _chatDialogHistoryBlock(messagesMArray ? messagesMArray:@[].mutableCopy, nil);
//                _chatDialogHistoryBlock = nil;
//            }
//        }
//	}
//}

@end
