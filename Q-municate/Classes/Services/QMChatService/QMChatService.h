//
//  QMChatService.h
//  Q-municate
//
//  Created by Igor Alefirenko on 17/02/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "QMChatUploadingMessage.h"

@interface QMChatService : NSObject <QBChatDelegate, QBActionStatusDelegate>
/**
 Authorize on QuickBlox Chat
 
 @param user QBUUser structure represents user's login. Required user's fields: ID, password;
 @return YES if the request was sent successfully. If not - see log.
 */
- (BOOL)loginWithUser:(QBUUser *)user completion:(QBChatResultBlock)block;

/**
 Logout current user from Chat
 
 @return YES if the request was sent successfully. If not - see log.
 */
- (BOOL)logout;
//@property (strong, nonatomic) NSMutableDictionary *allDialogsAsDictionary;
//
//
//@property (nonatomic, strong) QBChatRoom *chatRoom;
//
//@property (nonatomic, strong) QBChatDialog *lastCreatedDialog;
//@property (nonatomic, readonly, getter = isLoggedIn) BOOL loggedIn;
//
//+ (instancetype)shared;
//
//// Log In & Log Out
//- (void)loginWithUser:(QBUUser *)user completion:(QBChatResultBlock)block;
//- (void)logOut;
//
//#pragma mark - STATUS
//- (void)sendPresence;
//
//
//#pragma mark - Contact List (ROASTER)
//
//- (void)sendFriendsRequestToUserWithID:(NSUInteger)userID;
//- (void)confirmFriendsRequestFromUserWithID:(NSUInteger)userID;
//- (void)rejectFriendsRequestFromUserWithID:(NSUInteger)userID;
//- (void)removeContactFromFriendsWithID:(NSUInteger)userID;
//
//#pragma mark - CHAT
//
//- (void)setHistory:(NSArray *)history forIdentifier:(NSString *)identifier;
//- (NSArray *)historyWithIdentifier:(NSString *)identifier;
//
//- (QBChatRoom *)chatRoomWithRoomJID:(NSString *)roomJID;
//
//#pragma mark - Chat Dialogs
//
///** Getting all dialogs you exist */
//- (void)fetchAllDialogsWithCompletion:(void(^)(NSArray *dialogs, NSError *error))completionHandler;
//
//- (void)createPrivateChatDialogWithOpponent:(QBUUser *)opponent completion:(QBChatDialogResultBlock)completionHandler;
//
///** Create new QBChatDialog instance */
//- (void)createChatDialog:(QBChatDialog *)chatDialog withCompletion:(QBChatDialogResultBlock)completionHandler;
//
///** Changing name for QBChatDialog. Returns updated QBChatDialog */
//- (void)changeChatName:(NSString *)dialogName forChatDialog:(QBChatDialog *)chatDialog completion:(QBChatDialogResultBlock)completionHandler;
//
///** Add users to dialog. Returns updated QBChatDialog */
//- (void)addUsers:(NSArray *)users toChatDialog:(QBChatDialog *)chatDialog completion:(QBChatDialogResultBlock)completionHandler;
//
///** Leave chat dialog. Returns QBChatDialog without your ID in occupantsIDs */
//- (void)leaveChatDialog:(QBChatDialog *)chatDialog completion:(QBChatDialogResultBlock)completionHandler;
//
//
//#pragma mark - Chat Messages & Rooms
//
///** Send private message to user */
//- (void)sendMessage:(QBChatMessage *)message;
//
///** Send group chat message to current room */
//- (void)sendMessage:(QBChatMessage *)message toRoom:(QBChatRoom *)chatRoom;
//
///** Notification, that informs other participants about creating chat dialog. */
//- (void)sendChatDialogDidCreateNotificationToUsers:(NSArray *)users withChatDialog:(QBChatDialog *)chatDialog;
//
///** Notification, that informs other participants of dialog about dialog updates. Chat Dialog should contain chat dialog id. May contain occupants ids, or chat name */
//- (void)sendChatDialogDidUpdateNotificationToUsers:(NSArray *)users withChatDialog:(QBChatDialog *)chatDialog;
//
//- (void)sendContentMessage:(QMChatUploadingMessage *)message withBlob:(QBCBlob *)blob;
//
///** Creates QBChatRoom instance with room_jid field. */
//- (void)joinRoomWithRoomJID:(NSString *)roomJID;
//
//- (void)joinRoomsForDialogs:(NSArray *)chatDialogs;
//
//- (void)getMessageHistoryWithDialogID:(NSString *)dialogIDString withCompletion:(void(^)(NSArray *messages, BOOL success, NSError *error))block;
//
//
//#pragma mark - Chat Utils
//
//- (QBChatDialog *)chatDialogForFriendWithID:(NSUInteger)ID;
//- (QBChatMessage *)chatMessageFromContentMessage:(QMChatUploadingMessage *)uploadingMessage;
//
//
//#pragma mark - Audio/Video Calls
//
//- (void)callUser:(NSUInteger)userID opponentView:(QBVideoView *)opponentView callType:(QMVideoChatType)callType;
//- (void)acceptCallFromUser:(NSUInteger)userID opponentView:(QBVideoView *)opponentView;
//- (void)rejectCallFromUser:(NSUInteger)userID opponentView:(QBVideoView *)opponentView;
//
//- (void)cancelCall;
//- (void)finishCall;

@end
