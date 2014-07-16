//
//  QMChatReceiver.m
//  Qmunicate
//
//  Created by Andrey on 07.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMChatReceiver.h"

@interface QMChatHandlerObject : NSObject

@property (weak, nonatomic) id target;
@property (copy, nonatomic) id callback;

@end

@implementation QMChatHandlerObject

- (void)dealloc {
    NSLog(@"%@ %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
}

@end

@interface QMChatReceiver()

@property (strong, nonatomic) NSMutableDictionary *bloks;

@end

@implementation QMChatReceiver

+ (instancetype)instance {
    
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

- (void)destroy {
    
    self.bloks = [NSMutableDictionary dictionary];
}

- (instancetype)init {
    
    self = [super init];
    if (self) {
        self.bloks = [NSMutableDictionary dictionary];
    }
    
    return self;
}

- (void)subsribeWithTarget:(id)target selector:(SEL)selector block:(id)block {
    
    NSString *key = NSStringFromSelector(selector);
    NSMutableArray *array = self.bloks[key];
    
    if (!array) {
        array = [NSMutableArray array];
    }
    QMChatHandlerObject *handler = [[QMChatHandlerObject alloc] init];
    handler.callback = block;
    handler.target = target;
    
    [array addObject:handler];
    self.bloks[key] = array;
}

- (void)executeBloksWithSelector:(SEL)selector enumerateBloks:(void(^)(id block))enumerateBloks {
    
    NSString *key = NSStringFromSelector(selector);

    NSArray *bloksToExecute = self.bloks[key];
    
    for (QMChatHandlerObject *handler in bloksToExecute) {
        NSLog(@"\n------------------------------------------\nsend %@ notification to %@\n------------------------------------------", key, handler.target);
        enumerateBloks(handler.callback);
    }
}

#pragma mark - QMChatService

/**
 didLogin fired by QBChat when connection to service established and login is successfull
 */
- (void)chatDidLoginWithTarget:(id)target block:(QMChatDidLogin)block {
    [self subsribeWithTarget:target selector:@selector(chatDidLogin) block:block];
}

- (void)chatDidLogin {
    [self executeBloksWithSelector:_cmd enumerateBloks:^(QMChatDidLogin block) {
        block(YES);
    }];
}

/**
 didNotLogin fired when login process did not finished successfully
 */

- (void)chatDidNotLoginWithTarget:(id)target block:(QMChatDidLogin)block {
    [self subsribeWithTarget:target selector:@selector(chatDidLogin) block:block];
}

- (void)chatDidNotLogin {
    [self executeBloksWithSelector:_cmd enumerateBloks:^(QMChatDidLogin block) {
        block(NO);
    }];
}

/**
 didNotSendMessage fired when message cannot be send to user
 
 @param message Message passed to sendMessage method into QBChat
 */

- (void)chatDidNotSendMessageWithTarget:(id)target block:(QMChatDidNotSendMessage)block {
    [self subsribeWithTarget:target selector:@selector(chatDidNotSendMessage:) block:block];
}

- (void)chatDidNotSendMessage:(QBChatMessage *)message {
    [self executeBloksWithSelector:_cmd enumerateBloks:^(QMChatDidNotSendMessage block) {
        block(message);
    }];
}

/**
 didReceiveMessage fired when new message was received from QBChat
 
 @param message Message received from Chat
 */

- (void)chatDidReceiveMessageWithTarget:(id)target block:(QMChatDidReceiveMessage)block {
    [self subsribeWithTarget:target selector:@selector(chatDidReceiveMessage:) block:block];
}

- (void)chatDidReceiveMessage:(QBChatMessage *)message {
    [self executeBloksWithSelector:_cmd enumerateBloks:^(QMChatDidReceiveMessage block) {
        block(message);
    }];
}

/**
 didFailWithError fired when connection error occurs
 
 @param error Error code from QBChatServiceError enum
 */
- (void)chatDidFailWithTarget:(id)target block:(QMChatDidFailLogin)block {
    [self subsribeWithTarget:target selector:@selector(chatDidFailWithError:) block:block];
}

- (void)chatDidFailWithError:(NSInteger)code {
    [self executeBloksWithSelector:_cmd enumerateBloks:^(QMChatDidFailLogin block) {
        block(code);
    }];
}

/**
 Called in case receiving presence
 
 @param userID User ID from which received presence
 @param type Presence type
 */

- (void)chatDidReceivePresenceOfUserWithTarget:(id)target block:(QMChatDidReceivePresenceOfUser)block {
    [self subsribeWithTarget:target selector:@selector(chatDidReceivePresenceOfUser:type:) block:block];
}

- (void)chatDidReceivePresenceOfUser:(NSUInteger)userID type:(NSString *)type {
    [self executeBloksWithSelector:_cmd enumerateBloks:^(QMChatDidReceivePresenceOfUser block) {
        block(userID, type);
    }];
}

#pragma mark -
#pragma mark Contact list

/**
 Called in case receiving contact request
 
 @param userID User ID from which received contact request
 */

- (void)chatDidReceiveContactAddRequestWithTarget:(id)target block:(QMChatDidReceiveContactAddRequest)block {
    [self subsribeWithTarget:target selector:@selector(chatDidReceiveContactAddRequestFromUser:) block:block];
}

- (void)chatDidReceiveContactAddRequestFromUser:(NSUInteger)userID {
    [self executeBloksWithSelector:_cmd enumerateBloks:^(QMChatDidReceiveContactAddRequest block) {
        block(userID);
    }];
}

/**
 Called in case changing contact list
 */
- (void)chatContactListDidChangeWithTarget:(id)target block:(QMChatContactListDidChange)block {
    [self subsribeWithTarget:target selector:@selector(chatContactListDidChange:) block:block];
}

- (void)chatContactListDidChange:(QBContactList *)contactList {
    [self executeBloksWithSelector:_cmd enumerateBloks:^(QMChatContactListDidChange block) {
        block(contactList);
    }];
    [self chatContactListWillChange];

}

- (void)chatContactListWilChangeWithTarget:(id)target block:(QMChatContactListWillChange)block {
    [self subsribeWithTarget:target selector:@selector(chatContactListWillChange) block:block];
}

- (void)chatContactListWillChange {
    [self executeBloksWithSelector:_cmd enumerateBloks:^(QMChatContactListWillChange block) {
        block();
    }];
}


/**
 Called in case changing contact's online status
 
 @param userID User which online status has changed
 @param isOnline New user status (online or offline)
 @param status Custom user status
 */
- (void)chatDidReceiveContactItemActivityWithTarget:(id)target block:(QMChathatDidReceiveContactItemActivity)block {
    [self subsribeWithTarget:target selector:@selector(chatDidReceiveContactItemActivity:isOnline:status:) block:block];
}

- (void)chatDidReceiveContactItemActivity:(NSUInteger)userID isOnline:(BOOL)isOnline status:(NSString *)status {
    NSLog(@"\n------------------ROSTER------------------\n%@\n------------------------------------------", NSStringFromSelector(_cmd));
    [self executeBloksWithSelector:_cmd enumerateBloks:^(QMChathatDidReceiveContactItemActivity block) {
        block(userID, isOnline, status);
    }];
}

#pragma mark -
#pragma mark Rooms

/**
 Called in case received list of available to join rooms.
 
 @rooms Array of rooms
 */
- (void)chatDidReceiveListOfRoomsWithTarget:(id)target block:(QMChatDidReceiveListOfRooms)block {
    [self subsribeWithTarget:target selector:@selector(chatDidReceiveListOfRooms:) block:block];
}

- (void)chatDidReceiveListOfRooms:(NSArray *)rooms {
    [self executeBloksWithSelector:_cmd enumerateBloks:^(QMChatDidReceiveListOfRooms block) {
        block(rooms);
    }];
}
/**
 Called when room receives a message.
 
 @param message Received message
 @param roomJID Room JID
 */

- (void)chatRoomDidReceiveMessageWithTarget:(id)target block:(QMChatRoomDidReceiveMessage)block {
    [self subsribeWithTarget:target selector:@selector(chatRoomDidReceiveMessage:fromRoomJID:) block:block];
}

- (void)chatRoomDidReceiveMessage:(QBChatMessage *)message fromRoomJID:(NSString *)roomJID {
    [self executeBloksWithSelector:_cmd enumerateBloks:^(QMChatRoomDidReceiveMessage block) {
        block(message, roomJID);
    }];
}

/**
 Called when received room information.
 
 @param information Room information
 @param roomJID JID of room
 @param roomName Name of room
 */

- (void)chatRoomDidReceiveInformationWithTarget:(id)target block:(QMChatRoomDidReceiveInformation)block {
    [self subsribeWithTarget:target selector:@selector(chatRoomDidReceiveInformation:roomJID:roomName:) block:block];
}

- (void)chatRoomDidReceiveInformation:(NSDictionary *)information roomJID:(NSString *)roomJID roomName:(NSString *)roomName {
    [self executeBloksWithSelector:_cmd enumerateBloks:^(QMChatRoomDidReceiveInformation block) {
        block(information, roomJID, roomName);
    }];
}

/**
 Fired when room was successfully created
 */

- (void)chatRoomDidCreateWithTarget:(id)target block:(QMChatRoomDidCreate)block {
    [self subsribeWithTarget:target selector:@selector(chatRoomDidCreate:) block:block];
}

- (void)chatRoomDidCreate:(NSString*)roomName {
    [self executeBloksWithSelector:_cmd enumerateBloks:^(QMChatRoomDidCreate block) {
        block(roomName);
    }];
}

/**
 Fired when you did enter to room
 
 @param room which you have joined
 */

- (void)chatRoomDidEnterWithTarget:(id)target block:(QMChatRoomDidEnter)block {
    [self subsribeWithTarget:target selector:@selector(chatRoomDidEnter:) block:block];
}

- (void)chatRoomDidEnter:(QBChatRoom *)room {
    [self executeBloksWithSelector:_cmd enumerateBloks:^(QMChatRoomDidEnter block) {
        block(room);
    }];
}

/**
 Called when you didn't enter to room
 
 @param room which you haven't joined
 @param error Error
 */

- (void)chatRoomDidNotEnterWithTarget:(id)target block:(QMChatRoomDidNotEnter)block {
    [self subsribeWithTarget:target selector:@selector(chatRoomDidNotEnter:error:) block:block];
}

- (void)chatRoomDidNotEnter:(NSString *)roomName error:(NSError *)error {
    [self executeBloksWithSelector:_cmd enumerateBloks:^(QMChatRoomDidNotEnter block) {
        block(roomName, error);
    }];
}

/**
 Fired when you did leave room
 
 @param Name of room which you have leaved
 */
- (void)chatRoomDidLeaveWithTarget:(id)target block:(QMChatRoomDidLeave)block {
    [self subsribeWithTarget:target selector:@selector(chatRoomDidLeave:) block:block];
}

- (void)chatRoomDidLeave:(NSString *)roomName {
    [self executeBloksWithSelector:_cmd enumerateBloks:^(QMChatRoomDidLeave block) {
        block(roomName);
    }];
}

/**
 Fired when you did destroy room
 
 @param Name of room which you have destroyed
 */
- (void)chatRoomDidDestroyWithTarget:(id)target block:(QMChatRoomDidDestroy)block {
    [self subsribeWithTarget:target selector:@selector(chatRoomDidDestroy:) block:block];
}

- (void)chatRoomDidDestroy:(NSString *)roomName {
    [self executeBloksWithSelector:_cmd enumerateBloks:^(QMChatRoomDidDestroy block) {
        block(roomName);
    }];
}

/**
 Called in case changing online users
 
 @param onlineUsers Array of online users
 @param roomName Name of room in which have changed online users
 */
- (void)chatRoomDidChangeOnlineUsersWithTarget:(id)target block:(QMChatRoomDidChangeOnlineUsers)block {
    [self subsribeWithTarget:target selector:@selector(chatRoomDidChangeOnlineUsers:room:) block:block];
}

- (void)chatRoomDidChangeOnlineUsers:(NSArray *)onlineUsers room:(NSString *)roomName {
    [self executeBloksWithSelector:_cmd enumerateBloks:^(QMChatRoomDidChangeOnlineUsers block) {
        block(onlineUsers, roomName);
    }];
}

/**
 Called in case receiving list of users who can join room
 
 @param users Array of users which are able to join room
 @param roomName Name of room which provides access to join
 */
- (void)chatRoomDidReceiveListOfUsersWithTarget:(id)target block:(QMChatRoomDidReceiveListOfUsers)block {
    [self subsribeWithTarget:target selector:@selector(chatRoomDidReceiveListOfUsers:room:) block:block];
}

- (void)chatRoomDidReceiveListOfUsers:(NSArray *)users room:(NSString *)roomName {
    [self executeBloksWithSelector:_cmd enumerateBloks:^(QMChatRoomDidReceiveListOfUsers block) {
        block(users, roomName);
    }];
}

/**
 Called in case receiving list of active users (joined)
 
 @param users Array of joined users
 @param roomName Name of room
 */
- (void)chatRoomDidReceiveListOfOnlineUsersWithTarget:(id)target block:(QMChatRoomDidReceiveListOfOnlineUsers)block {
    [self subsribeWithTarget:target selector:@selector(chatRoomDidReceiveListOfOnlineUsers:room:) block:block];
}

- (void)chatRoomDidReceiveListOfOnlineUsers:(NSArray *)users room:(NSString *)roomName {
    [self executeBloksWithSelector:_cmd enumerateBloks:^(QMChatRoomDidReceiveListOfOnlineUsers block) {
        block(users, roomName);
    }];
}

#pragma mark -
#pragma mark Video Chat Called

/**
 Called in case when opponent is calling to you
 
 @param userID ID of uopponent
 @param conferenceType Type of conference. 'QBVideoChatConferenceTypeAudioAndVideo' and 'QBVideoChatConferenceTypeAudio' values are available
 */
- (void)chatDidReceiveCallRequestWithTarget:(id)target block:(QMChatDidReceiveCallRequest)block {
    [self subsribeWithTarget:target selector:@selector(chatDidReceiveCallRequestFromUser:withSessionID:conferenceType:) block:block];
}

- (void)chatDidReceiveCallRequestFromUser:(NSUInteger)userID
                            withSessionID:(NSString*)sessionID
                           conferenceType:(enum QBVideoChatConferenceType)conferenceType {
    
    [self executeBloksWithSelector:_cmd enumerateBloks:^(QMChatDidReceiveCallRequest block) {
        block(userID, sessionID, conferenceType);
    }];
}

/**
 Called in case when opponent is calling to you
 
 @param userID ID of uopponent
 @param conferenceType Type of conference. 'QBVideoChatConferenceTypeAudioAndVideo' and 'QBVideoChatConferenceTypeAudio' values are available
 @param customParameters Custom caller parameters
 */
- (void)chatDidReceiveCallRequestCustomParametesrWithTarget:(id)target block:(QMChatDidReceiveCallRequestCustomParams)block {
    [self subsribeWithTarget:target selector:@selector(chatDidReceiveCallRequestFromUser:withSessionID:conferenceType:customParameters:) block:block];
}

- (void)chatDidReceiveCallRequestFromUser:(NSUInteger)userID
                            withSessionID:(NSString*)sessionID
                           conferenceType:(enum QBVideoChatConferenceType)conferenceType
                         customParameters:(NSDictionary *)customParameters {
    
    [self executeBloksWithSelector:_cmd enumerateBloks:^(QMChatDidReceiveCallRequestCustomParams block) {
        block(userID, sessionID, conferenceType, customParameters);
    }];
}

/**
 Called in case when you are calling to user, but hi hasn't answered
 
 @param userID ID of opponent
 */
- (void)chatCallUserDidNotAnswerWithTarget:(id)target block:(QMChatCallUserDidNotAnswer)block {
    [self subsribeWithTarget:target selector:@selector(chatCallUserDidNotAnswer:) block:block];
}

- (void)chatCallUserDidNotAnswer:(NSUInteger)userID {
    [self executeBloksWithSelector:_cmd enumerateBloks:^(QMChatCallUserDidNotAnswer block) {
        block(userID);
    }];
}

/**
 Called in case when opponent has accepted you call
 
 @param userID ID of opponent
 */
- (void)chatCallDidAcceptWithTarget:(id)target block:(QMChatCallDidAcceptByUser)block {
    [self subsribeWithTarget:target selector:@selector(chatCallDidAcceptByUser:) block:block];
}

- (void)chatCallDidAcceptByUser:(NSUInteger)userID {
    [self executeBloksWithSelector:_cmd enumerateBloks:^(QMChatCallDidAcceptByUser block) {
        block(userID);
    }];
}

/**
 Called in case when opponent has accepted you call
 
 @param userID ID of opponent
 @param customParameters Custom caller parameters
 */

- (void)chatCallDidAcceptCustomParametersWithTarget:(id)target block:(QMChatCallDidAcceptByUserCustomParams)block {
    [self subsribeWithTarget:target selector:@selector(chatCallDidAcceptByUser:) block:block];
}

- (void)chatCallDidAcceptByUser:(NSUInteger)userID customParameters:(NSDictionary *)customParameters {
    [self executeBloksWithSelector:_cmd enumerateBloks:^(QMChatCallDidAcceptByUserCustomParams block) {
        block(userID, customParameters);
    }];
}

/**
 Called in case when opponent has rejected you call
 
 @param userID ID of opponent
 */
- (void)chatCallDidRejectByUserWithTarget:(id)target block:(QMChatCallDidRejectByUser)block {
    [self subsribeWithTarget:target selector:@selector(chatCallDidRejectByUser:) block:block];
}

- (void)chatCallDidRejectByUser:(NSUInteger)userID {
    [self executeBloksWithSelector:_cmd enumerateBloks:^(QMChatCallDidRejectByUser block) {
        block(userID);
    }];
}

/**
 Called in case when opponent has finished call
 
 @param userID ID of opponent
 @param status Reason of finish call. There are 2 reasons: 1) Opponent did not answer - 'kStopVideoChatCallStatus_OpponentDidNotAnswer'. 2) Opponent finish call with method 'finishCall' - 'kStopVideoChatCallStatus_Manually'
 */
- (void)chatCallDidStopWithTarget:(id)target block:(QMChatCallDidStopByUser)block {
    [self subsribeWithTarget:target selector:@selector(chatCallDidStopByUser:status:) block:block];
}

- (void)chatCallDidStopByUser:(NSUInteger)userID status:(NSString *)status {
    [self executeBloksWithSelector:_cmd enumerateBloks:^(QMChatCallDidStopByUser block) {
        block(userID, status);
    }];
}

/**
 Called in case when opponent has finished call
 
 @param userID ID of opponent
 @param status Reason of finish call. There are 2 reasons: 1) Opponent did not answer - 'kStopVideoChatCallStatus_OpponentDidNotAnswer'. 2) Opponent finish call with method 'finishCall' - 'kStopVideoChatCallStatus_Manually'
 @param customParameters Custom caller parameters
 */
- (void)chatCallDidStopCustomParametersWithTarget:(id)target block:(QMChatCallDidStopByUserCustomParams)block {
    [self subsribeWithTarget:target selector:@selector(chatCallDidStopByUser:status:customParameters:) block:block];
}

- (void)chatCallDidStopByUser:(NSUInteger)userID status:(NSString *)status customParameters:(NSDictionary *)customParameters {
    [self executeBloksWithSelector:_cmd enumerateBloks:^(QMChatCallDidStopByUserCustomParams block) {
        block(userID, status, customParameters);
    }];
}

/**
 Called in case when call has started
 
 @param userID ID of opponent
 @param sessionID ID of session
 */
- (void)chatCallDidStartWithTarget:(id)target block:(QMChathatCallDidStartWithUser)block {
    [self subsribeWithTarget:target selector:@selector(chatCallDidStartWithUser:sessionID:) block:block];
}

- (void)chatCallDidStartWithUser:(NSUInteger)userID sessionID:(NSString *)sessionID {
    [self executeBloksWithSelector:_cmd enumerateBloks:^(QMChathatCallDidStartWithUser block) {
        block(userID, sessionID);
    }];
}

/**
 Called in case when start using TURN relay for video chat (not p2p).
 */
- (void)didStartUseTURNForVideoChatWithTarget:(id)target block:(QMDidStartUseTURNForVideoChat)block {
    [self subsribeWithTarget:target selector:@selector(didStartUseTURNForVideoChat) block:block];
}

- (void)didStartUseTURNForVideoChat {
    [self executeBloksWithSelector:_cmd enumerateBloks:^(QMDidStartUseTURNForVideoChat block) {
        block();
    }];
}

@end
