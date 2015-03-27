//
//  QMChatReceiver.m
//  Qmunicate
//
//  Created by Andrey Ivanov on 07.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMChatReceiver.h"
#import "NSString+GTMNSStringHTMLAdditions.h"

@interface QMChatHandlerObject : NSObject

@property (weak, nonatomic) id target;
@property (strong, nonatomic) id callback;
@property (assign, nonatomic) NSUInteger identifier;
@property (strong, nonatomic) NSString *className;
@property (strong, nonatomic) NSString *tcmd;

@end

@implementation QMChatHandlerObject

- (void)dealloc {
    ILog(@"%@ %@", self.description, NSStringFromSelector(_cmd));
}

- (NSString *)description {
    
    return [NSString stringWithFormat:
            @"cmd - %@, callback - %@, identfier - %zd, targetClass - %@",
            self.tcmd, self.callback, self.identifier, self.className];
}

- (BOOL)isEqual:(QMChatHandlerObject *)other {
    
    if(other == self || [super isEqual:other] || [self.target isEqual:other.target] || self.identifier == other.identifier){
        return YES;
    }
    return NO;
}

- (NSUInteger)hash {
    return self.identifier;
}

@end

@interface QMChatReceiver()

@property (strong, nonatomic) NSMutableDictionary *handlerList;

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

- (instancetype)init {
    
    self = [super init];
    if (self) {
        self.handlerList = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)unsubscribeForTarget:(id)target {
    
    NSArray *allHendlers = [self.handlerList allValues];
    
    NSUInteger identifier = [target hash];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SUBQUERY(self, $x, $x.identifier == %d).@count != 0", identifier];
    NSArray *result = [allHendlers filteredArrayUsingPredicate:predicate];
    
    for (NSMutableSet *handlers in result) {
    
        NSMutableSet *minusSet = [NSMutableSet set];
        
        for (QMChatHandlerObject *handler in handlers) {
            
            if (handler.identifier == identifier) {
                [minusSet addObject:handler];
            }
        }
        
        [handlers minusSet:minusSet];
    }
}

- (void)subsribeWithTarget:(id)target selector:(SEL)selector block:(id)block {
    
    NSString *key = NSStringFromSelector(selector);
    NSMutableSet *handlers = self.handlerList[key];
    
    if (!handlers) {
        handlers = [NSMutableSet set];
    }
    
    QMChatHandlerObject *handler = [[QMChatHandlerObject alloc] init];
    handler.callback = [block copy];
    handler.target = target;
    handler.identifier = [target hash];
    handler.className = NSStringFromClass([target class]);
    handler.tcmd = key;
    
#if QM_TEST
    if (handlers.count > 0)
    for (QMChatHandlerObject * test_handler in handlers) {
        NSAssert(![test_handler isEqual:handler], @"Check this case");
    }
#endif
    
    ILog(@"Subscirbe:%@", [handler description]);
    [handlers addObject:handler];
    self.handlerList[key] = handlers;
}

- (void)executeBloksWithSelector:(SEL)selector enumerateBloks:(void(^)(id block))enumerateBloks {
    
    NSString *key = NSStringFromSelector(selector);

    NSMutableSet *toExecute = self.handlerList[key];
    
    for (QMChatHandlerObject *handler in toExecute) {
        if (handler.callback) {
            ILog(@"Send %@ notification to %@", key, handler.target);
            enumerateBloks(handler.callback);
        }
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
    ILog(@"Chat Did login");
    [self executeBloksWithSelector:_cmd enumerateBloks:^(QMChatDidLogin block) {
        block(YES);
    }];
}

/**
 didNotLogin fired when login process did not finished successfully
 */

- (void)chatDidNotLoginWithTarget:(id)target block:(QMChatDidLogin)block {
    [self subsribeWithTarget:target selector:@selector(chatDidNotLogin) block:block];
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

- (void)chatDidNotSendMessageWithTarget:(id)target block:(QMChatMessageBlock)block {
    [self subsribeWithTarget:target selector:@selector(chatDidNotSendMessage:) block:block];
}

- (void)chatDidNotSendMessage:(QBChatMessage *)message {
    [self executeBloksWithSelector:_cmd enumerateBloks:^(QMChatMessageBlock block) {
        block(message);
    }];
}

/**
 didReceiveMessage fired when new message was received from QBChat
 
 @param message Message received from Chat
 */

- (void)chatDidReceiveMessageWithTarget:(id)target block:(QMChatMessageBlock)block {
    [self subsribeWithTarget:target selector:@selector(chatDidReceiveMessage:) block:block];
}

- (void)chatDidReceiveMessage:(QBChatMessage *)message {
    message.text = [message.text gtm_stringByUnescapingFromHTML];
    [self executeBloksWithSelector:_cmd enumerateBloks:^(QMChatMessageBlock block) {
        block(message);
    }];
    if (message.cParamNotificationType == QMMessageNotificationTypeSendContactRequest) {
        return;
    }
    [self chatAfterDidReceiveMessage:message];
}

- (void)chatDidDeliverMessageWithID:(NSString *)messageID
{
    ILog(@"Message was delivered to user. Message ID: %@", messageID);
}

- (void)chatDidReadMessageWithID:(NSString *)messageID
{
    
}

- (void)chatAfterDidReceiveMessageWithTarget:(id)target block:(QMChatMessageBlock)block {
    [self subsribeWithTarget:target selector:@selector(chatAfterDidReceiveMessage:) block:block];
}

- (void)chatAfterDidReceiveMessage:(QBChatMessage *)message {
    [self executeBloksWithSelector:_cmd enumerateBloks:^(QMChatMessageBlock block) {
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

- (void)chatDidFailWithStreamError:(NSError *)error {
    [self executeBloksWithSelector:_cmd enumerateBloks:^(QMChatDidFailLogin block) {
        block(error);
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
    NSLog(@"User %d", userID);
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
    [self chatContactListUpdated];

}

- (void)chatContactListUpdatedWithTarget:(id)target block:(QMChatContactListWillChange)block {
    [self subsribeWithTarget:target selector:@selector(chatContactListUpdated) block:block];
}

- (void)chatContactListUpdated {
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
    message.text = [message.text gtm_stringByUnescapingFromHTML];
    if (!message.ID || !message.customParameters) {
        return;
    }
    [self executeBloksWithSelector:_cmd enumerateBloks:^(QMChatRoomDidReceiveMessage block) {
        block(message, roomJID);
    }];
    
    if (message.cParamNotificationType <= 0) {
        [self chatAfterDidReceiveMessage:message];
    }
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
#pragma mark InternetConnection Notifications

- (void)internetConnectionIsActive:(BOOL)isActive
{
    [self executeBloksWithSelector:_cmd enumerateBloks:^(QMInternetConnectionState block){
        block(isActive);
    }];
}

- (void)internetConnectionStateWithTarget:(id)target block:(QMInternetConnectionState)block {
    [self subsribeWithTarget:target selector:@selector(internetConnectionIsActive:) block:block];
}

@end
