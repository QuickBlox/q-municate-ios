//
//  QBChat.h
//  Chat
//
//  Copyright 2013 QuickBlox team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Quickblox/QBNullability.h>
#import <Quickblox/QBGeneric.h>
#import <AVFoundation/AVFoundation.h>
#import "ChatEnums.h"

@protocol QBChatDelegate;
@class QBUUser;
@class QBContactList;
@class QBChatMessage;
@class QBChatDialog;
@class QBPrivacyList;

/**
 QBChatServiceError enum defines following connection error codes:
 QBChatServiceErrorConnectionRefused - Connection with server is not available
 QBChatServiceErrorConnectionClosed  - Chat service suddenly became unavailable
 QBChatServiceErrorConnectionTimeout - Connection with server timed out
 */
typedef enum QBChatServiceError {
    QBChatServiceErrorConnectionClosed = 1,
    QBChatServiceErrorConnectionTimeout
} QBChatServiceError;

/** QBChat class declaration. */
/** Overview */
/** This class is the main entry point to work with Quickblox Chat API. */

@interface QBChat : NSObject 

/** Contact list */
@property (nonatomic, readonly, QB_NULLABLE_PROPERTY) QBContactList *contactList;

/** Enable or disable message carbons */
@property (nonatomic, assign, getter = isCarbonsEnabled) BOOL carbonsEnabled;

/** Enable or disable Stream Management (XEP-0198) */
@property (nonatomic, assign, getter = isStreamManagementEnabled) BOOL streamManagementEnabled;

/** Enable or disable Stream Resumption (XEP-0198). Works only if streamManagementEnabled=YES. */
@property (nonatomic, assign, getter = isStreamResumptionEnabled) BOOL streamResumptionEnabled;

/** The timeout value for Stream Management send a message operation */
@property (nonatomic, assign) int streamManagementSendMessageTimeout;

/** Enable or disable auto reconnect */
@property (nonatomic, assign, getter = isAutoReconnectEnabled) BOOL autoReconnectEnabled;

/** A reconnect timer may optionally be used to attempt a reconnect periodically.
  The default value is 5 seconds */
@property (nonatomic, assign) NSTimeInterval reconnectTimerInterval;

/**
 * Many routers will teardown a socket mapping if there is no activity on the socket.
 * For this reason, the stream supports sending keep-alive data.
 * This is simply whitespace, which is ignored by the protocol.
 *
 * Keep-alive data is only sent in the absence of any other data being sent/received.
 *
 * The default value is 20s.
 * The minimum value for TARGET_OS_IPHONE is 10s, else 20s.
 *
 * To disable keep-alive, set the interval to zero (or any non-positive number).
 *
 * The keep-alive timer (if enabled) fires every (keepAliveInterval / 4) seconds.
 * Upon firing it checks when data was last sent/received,
 * and sends keep-alive data if the elapsed time has exceeded the keepAliveInterval.
 * Thus the effective resolution of the keepalive timer is based on the interval.
 */
@property (nonatomic, assign) NSTimeInterval keepAliveInterval;

/** Background mode for stream. By default is NO. Should be set before login to chat. Does not work on simulator. */
@property (nonatomic, assign, getter = isBackgroundingEnabled) BOOL backgroundingEnabled;

- (QB_NONNULL id)init __attribute__((unavailable("'init' is not a supported initializer for this class.")));

#pragma mark -
#pragma mark Multicaste Delegate

/** 
 Adds the given delegate implementation to the list of observers
 
 @param delegate The delegate to add
 */
- (void)addDelegate:(QB_NONNULL id<QBChatDelegate>)delegate;

/** 
 Removes the given delegate implementation from the list of observers
 
 @param delegate The delegate to remove
 */
- (void)removeDelegate:(QB_NONNULL id<QBChatDelegate>)delegate;

/** Removes all delegates */
- (void)removeAllDelegates;

/** Array of all delegates*/
- (QB_NULLABLE NSArray QB_GENERIC(id<QBChatDelegate>) *)delegates;


#pragma mark -
#pragma mark Reconnection

/**
 Run force reconnect. This method disconnects from chat and runs reconnection logic. Works only if autoReconnectEnabled=YES. Otherwise it does nothing.
 */
- (void)forceReconnect;


#pragma mark -
#pragma mark Base Messaging

/**
 Get QBChat singleton
 
 @return QBChat Chat service singleton
 */
+ (QB_NONNULL instancetype)instance;

/**
 Authorize on QuickBlox Chat
 
 @param user QBUUser structure represents user's login. Required user's fields: ID, password;
 
 @warning *Deprecated in QB iOS SDK 2.4.4:* Use 'connectWithUser:' instead.
 
 @return YES if the request was sent successfully. If not - see log.
 */
- (BOOL)loginWithUser:(QB_NONNULL QBUUser *)user DEPRECATED_MSG_ATTRIBUTE("Use connectWithUser: instead.");

/**
 * Connect to QuickBlox Chat
 *
 * @param user QBUUser structure represents user's login. Required user's fields: ID, password;
 *
 * @return YES if the request was sent successfully. If not - see log.
 */
- (BOOL)connectWithUser:(QB_NONNULL QBUUser *)user;

/**
 Authorize on QuickBlox Chat
 
 @param user QBUUser structure represents user's login. Required user's fields: ID, password.
 @param resource The resource identifier of user.
 
 @warning *Deprecated in QB iOS SDK 2.4.4:* Use 'connectWithUser:resource:' instead.
 
 @return YES if the request was sent successfully. If not - see log.
 */
- (BOOL)loginWithUser:(QB_NONNULL QBUUser *)user resource:(QB_NULLABLE NSString *)resource DEPRECATED_MSG_ATTRIBUTE("Use 'connectWithUser:resource:' instead.");

/**
 * Connect to QuickBlox Chat
 *
 * @param user QBUUser structure represents user's login. Required user's fields: ID, password.
 * @param resource The resource identifier of user.
 *
 * @return YES if the request was sent successfully. If not - see log.
 */
- (BOOL)connectWithUser:(QB_NONNULL QBUUser *)user resource:(QB_NULLABLE NSString *)resource;

/**
 Check if current user logged into Chat
 
 @warning *Deprecated in QB iOS SDK 2.4.4:* Use 'isConnected' instead.
 
 @return YES if user is logged in, NO otherwise
 */
- (BOOL)isLoggedIn DEPRECATED_MSG_ATTRIBUTE("Use isConnected instead.");

/**
 * Check if current user connected to Chat
 *
 * @return YES if user is connected in, NO otherwise
 */
- (BOOL)isConnected;

/**
 Logout current user from Chat
 
 @warning *Deprecated in QB iOS SDK 2.4.4:* Use 'disconnect' instead.
 
 @return YES if the request was sent successfully. If not - see log.
 */
- (BOOL)logout DEPRECATED_MSG_ATTRIBUTE("Use 'disconnect' instead.");

/**
 * Disconnect current user from Chat
 *
 * @return YES if the request was sent successfully. If not - see log.
 */
- (BOOL)disconnect;

/**
 Send "read" status for message and update "read" status on a server
 
 @param message QBChatMessage message to mark as read.
 @return YES if the request was sent successfully. If not - see log.
 */
- (BOOL)readMessage:(QB_NONNULL QBChatMessage *)message;

/**
 *  Send "delivered" status for message.
 *
 *  @param message QBChatMessage message to mark as delivered.
 *
 *  @return YES if the request was sent successfully. If not - see log.
 */
- (BOOL)markAsDelivered:(QB_NONNULL QBChatMessage *)message;

/**
 Send presence message. Session will be closed in 90 seconds since last activity.
 
 @return YES if the request was sent successfully. If not - see log.
 */
- (BOOL)sendPresence;

/**
 Send presence message with status. Session will be closed in 90 seconds since last activity.
 
 @return YES if the request was sent successfully. If not - see log.
 */
- (BOOL)sendPresenceWithStatus:(QB_NONNULL NSString *)status;

/**
 Get current chat user
 
 @return An instance of QBUUser
 */
- (QB_NULLABLE QBUUser *)currentUser;


#pragma mark -
#pragma mark Contact list

/**
 Add user to contact list request
 
 @param userID ID of user which you would like to add to contact list
 @return YES if the request was sent successfully. If not - see log.
 */
- (BOOL)addUserToContactListRequest:(NSUInteger)userID;

/**
 Add user to contact list request
 
 @param userID ID of user which you would like to add to contact list
 @param sentBlock The block which informs whether a request was delivered to server or not. nil if no errors.
 @return YES if the request was sent. If not - see log.
 */
- (BOOL)addUserToContactListRequest:(NSUInteger)userID sentBlock:(QB_NULLABLE void (^)(NSError * QB_NULLABLE_S error))sentBlock;

/**
 Remove user from contact list
 
 @param userID ID of user which you would like to remove from contact list
 @return YES if the request was sent successfully. If not - see log.
 */
- (BOOL)removeUserFromContactList:(NSUInteger)userID;

/**
 Remove user from contact list
 
 @param userID ID of user which you would like to remove from contact list
 @param sentBlock The block which informs whether a request was delivered to server or not. nil if no errors.
 @return YES if the request was sent. If not - see log.
 */
- (BOOL)removeUserFromContactList:(NSUInteger)userID sentBlock:(QB_NULLABLE void (^)(NSError * QB_NULLABLE_S error))sentBlock;

/**
 Confirm add to contact list request
 
 @param userID ID of user from which you would like to confirm add to contact request
 @return YES if the request was sent successfully. If not - see log.
 */
- (BOOL)confirmAddContactRequest:(NSUInteger)userID;

/**
 Confirm add to contact list request
 
 @param userID ID of user from which you would like to confirm add to contact request
 @param sentBlock The block which informs whether a request was delivered to server or not. nil if no errors.
 @return YES if the request was sent. If not - see log.
 */
- (BOOL)confirmAddContactRequest:(NSUInteger)userID sentBlock:(QB_NULLABLE void (^)(NSError * QB_NULLABLE_S error))sentBlock;

/**
 Reject add to contact list request or cancel previously-granted subscription request 
 
 @param userID ID of user from which you would like to reject add to contact request
 @return YES if the request was sent successfully. If not - see log.
 */
- (BOOL)rejectAddContactRequest:(NSUInteger)userID;

/**
 Reject add to contact list request or cancel previously-granted subscription request
 
 @param userID ID of user from which you would like to reject add to contact request
 @param sentBlock The block which informs whether a request was delivered to server or not. nil if no errors.
 @return YES if the request was sent. If not - see log.
 */
- (BOOL)rejectAddContactRequest:(NSUInteger)userID sentBlock:(QB_NULLABLE void (^)(NSError * QB_NULLABLE_S error))sentBlock;

#pragma mark -
#pragma mark Privacy

/**
 Retrieve a privacy list by name. QBChatDelegate's method 'didReceivePrivacyList:' will be called if success or 'didNotReceivePrivacyListWithName:error:' if there is an error
 @param privacyListName name of privacy list
 */
- (void)retrievePrivacyListWithName:(QB_NONNULL NSString *)privacyListName;

/**
 Retrieve privacy list names. QBChatDelegate's method 'didReceivePrivacyListNames:' will be called if success or 'didNotReceivePrivacyListNamesDueToError:' if there is an error
 */
- (void)retrievePrivacyListNames;

/**
 Create/edit a privacy list. QBChatDelegate's method 'didReceivePrivacyList:' will be called
 
 @param privacyList instance of QBPrivacyList
 */
- (void)setPrivacyList:(QB_NULLABLE QBPrivacyList *)privacyList;

/**
 Set an active privacy list. QBChatDelegate's method 'didSetActivePrivacyListWithName:' will be called if success or 'didNotSetActivePrivacyListWithName:error:' if there is an error
 
 @param privacyListName name of privacy list
 */
- (void)setActivePrivacyListWithName:(QB_NULLABLE NSString *)privacyListName;

/**
 Set a default privacy list. QBChatDelegate's method 'didSetDefaultPrivacyListWithName:' will be called if success or 'didNotSetDefaultPrivacyListWithName:error:' if there is an error
 
 @param privacyListName name of privacy list
 */
- (void)setDefaultPrivacyListWithName:(QB_NULLABLE NSString *)privacyListName;

/**
 Remove a privacy list. QBChatDelegate's method 'didRemovedPrivacyListWithName:' will be called if success or 'didNotSetPrivacyListWithName:error:' if there is an error
 
 @param privacyListName name of privacy list
 */
- (void)removePrivacyListWithName:(QB_NONNULL NSString *)privacyListName;

#pragma mark -
#pragma mark System Messages

/**
 *  Send system message to dialog.
 *
 *  @param message Chat message to send.
 *
 *  @return YES if the message was sent. If not - see log.
 */
- (BOOL)sendSystemMessage:(QB_NONNULL QBChatMessage *)message;

@end
