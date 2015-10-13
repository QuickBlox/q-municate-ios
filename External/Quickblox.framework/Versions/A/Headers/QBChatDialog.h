//
//  QBChatDialog.h
//  Quickblox
//
//  Created by Igor Alefirenko on 23/04/2014.
//  Copyright (c) 2014 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Quickblox/QBNullability.h>
#import <Quickblox/QBGeneric.h>
#import "ChatEnums.h"

typedef void(^QBChatDialogStatusBlock)();
typedef void(^QBChatDialogRequestOnlineUsersBlock)(NSMutableArray QB_GENERIC(NSNumber *) * QB_NULLABLE_S onlineUsers);
typedef void(^QBChatDialogJoinFailedBlock)(NSError * QB_NULLABLE_S error);
typedef void(^QBChatDialogIsTypingBlock)(NSUInteger userID);
typedef void(^QBChatDialogStoppedTypingBlock)(NSUInteger userID);
typedef void(^QBChatDialogOccupantJoinBlock)(NSUInteger userID);
typedef void(^QBChatDialogOccupantLeaveBlock)(NSUInteger userID);
typedef void(^QBChatDialogOccupantUpdateBlock)(NSUInteger userID);

@class QBChatMessage;
@interface QBChatDialog : NSObject <NSCoding, NSCopying>

/** Object ID */
@property (nonatomic, retain, readonly, QB_NULLABLE_PROPERTY) NSString *ID;

/** Created date */
@property (nonatomic, retain, QB_NULLABLE_PROPERTY) NSDate *createdAt;

/** Updated date */
@property (nonatomic, retain, QB_NULLABLE_PROPERTY) NSDate *updatedAt;

/** Room JID. If private chat, room JID will be nil */
@property (nonatomic, retain, QB_NULLABLE_PROPERTY) NSString *roomJID;

/** Chat type: Private/Group/PublicGroup */
@property (nonatomic, readonly) QBChatDialogType type;

/** Group chat name. If chat type is private, name will be nil */
@property (nonatomic, retain, QB_NULLABLE_PROPERTY) NSString *name;

/** Group chat photo. Can contain a link to a file in Content module, Custom Objects module or just a web link. */
@property (nonatomic, retain, QB_NULLABLE_PROPERTY) NSString *photo;

/** Last message text in private or group chat */
@property (nonatomic, retain, QB_NULLABLE_PROPERTY) NSString *lastMessageText;

/** Date of last message in private or group chat */
@property (nonatomic, retain, QB_NULLABLE_PROPERTY) NSDate *lastMessageDate;

/** User ID of last opponent in private or group chat */
@property (nonatomic, assign) NSUInteger lastMessageUserID;

/** Number of unread messages in this dialog */
@property (nonatomic, assign) NSUInteger unreadMessagesCount;

/** Array of user ids in chat. For private chat count = 2 */
@property (nonatomic, retain, QB_NULLABLE_PROPERTY) NSArray QB_GENERIC(NSNumber *) *occupantIDs;

/** The dictionary with data */
@property (nonatomic, retain, QB_NULLABLE_PROPERTY) NSDictionary QB_GENERIC(NSString *, id) *data;

/** Dialog owner */
@property (nonatomic, assign) NSUInteger userID;

/** ID of a recipient if type = QBChatDialogTypePrivate. -1 otherwise.  */
@property (nonatomic, readonly) NSInteger recipientID;

/**
 *  Fired when user joined to room.
 */
@property (nonatomic, copy, QB_NULLABLE_PROPERTY) QBChatDialogStatusBlock onJoin;
- (void)setOnJoin:(QB_NULLABLE QBChatDialogStatusBlock)anOnJoin;

/**
 *  Fired when user left room.
 */
@property (nonatomic, copy, QB_NULLABLE_PROPERTY) QBChatDialogStatusBlock onLeave;
- (void)setOnLeave:(QB_NULLABLE QBChatDialogStatusBlock)anOnLeave;

/**
 *  Fired when list of online users received.
 */
@property (nonatomic, copy, QB_NULLABLE_PROPERTY) QBChatDialogRequestOnlineUsersBlock onReceiveListOfOnlineUsers;
- (void)setOnReceiveListOfOnlineUsers:(QB_NULLABLE QBChatDialogRequestOnlineUsersBlock)anOnReceiveListOfOnlineUsers;

/**
 *  Fired when join to room failed (in most cases if user is not added to the room)
 */
@property (nonatomic, copy, QB_NULLABLE_PROPERTY) QBChatDialogJoinFailedBlock onJoinFailed;
- (void)setOnJoinFailed:(QB_NULLABLE QBChatDialogJoinFailedBlock)anOnJoinFailed;

/**
 *  Fired when user is typing in dialog.
 */
@property (nonatomic, copy, QB_NULLABLE_PROPERTY) QBChatDialogIsTypingBlock onUserIsTyping;
- (void)setOnUserIsTyping:(QB_NULLABLE QBChatDialogIsTypingBlock)anOnUserIsTyping;

/**
 *  Fired when user stopped typing in dialog.
 */
@property (nonatomic, copy, QB_NULLABLE_PROPERTY) QBChatDialogStoppedTypingBlock onUserStoppedTyping;
- (void)setOnUserStoppedTyping:(QB_NULLABLE QBChatDialogStoppedTypingBlock)anOnUserStoppedTyping;

/**
 *  Fired when occupant joined to dialog.
 */
@property (nonatomic, copy, QB_NULLABLE_PROPERTY) QBChatDialogOccupantJoinBlock onJoinOccupant;
- (void)setOnJoinOccupant:(QB_NULLABLE QBChatDialogOccupantJoinBlock)onJoinOccupant;

/**
 *  Fired when occupant left dialog.
 */
@property (nonatomic, copy, QB_NULLABLE_PROPERTY) QBChatDialogOccupantLeaveBlock onLeaveOccupant;
- (void)setOnLeaveOccupant:(QB_NULLABLE QBChatDialogOccupantLeaveBlock)onLeaveOccupant;

/**
 *  Fired when occupant was update in dialog.
 */
@property (nonatomic, copy, QB_NULLABLE_PROPERTY) QBChatDialogOccupantUpdateBlock onUpdateOccupant;
- (void)setOnUpdateOccupant:(QB_NULLABLE QBChatDialogOccupantUpdateBlock)onUpdateOccupant;


/** Constructor */
- (QB_NONNULL instancetype)initWithDialogID:(QB_NULLABLE NSString *)dialogID type:(enum QBChatDialogType)type;

- (QB_NONNULL id)init __attribute__((unavailable("'init' is not a supported initializer for this class.")));
+ (QB_NONNULL id)new __attribute__((unavailable("'new' is not a supported initializer for this class.")));
/** Occupants ids to push. Use for update dialog */
- (void)setPushOccupantsIDs:(QB_NONNULL NSArray QB_GENERIC(NSString *) *)occupantsIDs;
- (QB_NULLABLE NSArray QB_GENERIC(NSString *) *)pushOccupantsIDs;

/** Occupants ids to pull. Use for update dialog */
- (void)setPullOccupantsIDs:(QB_NONNULL NSArray QB_GENERIC(NSString *) *)occupantsIDs;
- (QB_NULLABLE NSArray QB_GENERIC(NSString *) *)pullOccupantsIDs;

#pragma mark - Send message

/**
 *  Send chat message to dialog.
 *
 *  @param message Chat message to send.
 *
 *  @return YES if the message was sent. If not - see log.
 */
- (BOOL)sendMessage:(QB_NONNULL QBChatMessage *)message;

/**
 *  Send chat message with sent block
 *
 *  @param message   Chat message to send
 *  @param sentBlock The block which informs whether a message was delivered to server or not. nil if no errors.
 *
 *  @return YES if the message was sent. If not - see log.
 */
- (BOOL)sendMessage:(QB_NONNULL QBChatMessage *)message sentBlock:(QB_NULLABLE void (^)(NSError * QB_NULLABLE_S error))sentBlock;

/**
 *Available only for 'Enterprise' clients.* Send group chat message to room, without room join
 
 @param message Chat message to send
 @return YES if the request was sent successfully. If not - see log.
 */
- (BOOL)sendGroupChatMessageWithoutJoin:(QB_NONNULL QBChatMessage *)message;
#pragma mark - Join/leave

/**
 *  Join status of room
 *
 *  @return YES if user is joined to room, otherwise - no.
 */
- (BOOL)isJoined;

/**
 *  Join to room. 'onJoin' block will be called.
 *
 *  @return YES if the request was sent successfully. If not - see log.
 */
- (BOOL)join;

/**
 *  Leave joined room. 'onLeave' block will be called.
 *
 *  @return YES if the request was sent successfully. If not - see log.
 */
- (BOOL)leave;

/**
 *  Clears dialog occupants status blocks. Call this method if you don't want to recieve join/leave/update for this dialog.
 */
- (void)clearDialogOccupantsStatusBlock;

#pragma mark - Users status

/**
 *  Requests users who are joined to room. 'onReceiveListOfOnlineUsers' block will be called.
 *
 *  @return YES if the request was sent successfully. If not - see log.
 */
- (BOOL)requestOnlineUsers;

#pragma mark - Now typing

/**
 *  Send is typing message to occupants.
 */
- (void)sendUserIsTyping;

/**
 *  Send stopped typing message to occupants.
 */
- (void)sendUserStoppedTyping;

/**
 *  Clears typing status blocks. Call this method if you don't want to recieve typing statuses for this dialog.
 */
- (void)clearTypingStatusBlocks;

@end
