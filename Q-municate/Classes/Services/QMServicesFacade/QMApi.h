//
//  QMServicesFacade.h
//  Qmunicate
//
//  Created by Andrey on 01.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

@class QMAuthService;
@class QMSettingsManager;
@class QMFacebookService;
@class QMUsersService;
@class QMChatService;
@class QMChatDialogsService;
@class QMAVCallService;
@class QMMessagesService;
@class QMChatReceiver;

@interface QMApi : NSObject

@property (strong, nonatomic) QMAuthService *authService;
@property (strong, nonatomic) QMSettingsManager *settingsManager;
@property (strong, nonatomic) QMFacebookService *facebookService;
@property (strong, nonatomic) QMUsersService *usersService;
@property (strong, nonatomic) QMChatService *chatService;
@property (strong, nonatomic) QMAVCallService *avCallService;
@property (strong, nonatomic) QMChatDialogsService *chatDialogsService;
@property (strong, nonatomic) QMMessagesService *messagesService;
@property (strong, nonatomic) QMChatReceiver *responceService;

@property (strong, atomic) QBUUser *currentUser;

+ (instancetype)instance;
- (void)fetchAllHistory;
- (BOOL)checkResult:(Result *)result;
- (void)cleanUp;

@end

@interface QMApi (Auth)

/**
 User LogIn with facebook
 
 Type of Result - QBUUserLogInResult
 @return completion stastus
 */

- (void)setAutoLogin:(BOOL)autologin;

- (void)logout;

- (void)loginWithFacebook:(void(^)(BOOL success))completion;

/**
 */
- (void)loginWithUser:(QBUUser *)user completion:(QBUUserLogInResultBlock)complition;

/**
 */
- (void)signUpAndLoginWithUser:(QBUUser *)user userAvatar:(UIImage *)userAvatar completion:(QBUUserResultBlock)completion;

/**
 */
- (void)updateUser:(QBUUser *)user completion:(void(^)(BOOL success))completion;

/**
 */
- (void)changePasswordForCurrentUser:(QBUUser *)currentUser completion:(void(^)(BOOL success))completion;

/**
 */
- (void)resetUserPassordWithEmail:(NSString *)email completion:(void(^)(BOOL success))completion;

- (void)destroySessionWithCompletion:(void(^)(BOOL success))completion;

@end

@interface QMApi (Messages)

- (void)fetchMessageWithDialog:(QBChatDialog *)chatDialog complete:(void(^)(BOOL success))complete;
/**
 */
- (NSArray *)messagesHistoryWithDialog:(QBChatDialog *)chatDialog;
/**
 if ok return QBChatMessage , else nil
 */
- (QBChatMessage *)sendText:(NSString *)text toDialog:(QBChatDialog *)dialog;

@end

@interface QMApi (ChatDialogs)

- (NSArray *)dialogHistory;
- (NSArray *)allOccupantIDsFromDialogsHistory;

/**
 Get all dialogs for current user
 */
- (void)fetchAllDialogs:(void(^)(void))completion;

/**
 Create group chat dialog
 
 @param name - Group chat name.
 @param ocupants - Array of QBUUser in chat.
 @result QBChatDialogResult
 */
- (void)createGroupChatDialogWithName:(NSString *)name ocupants:(NSArray *)ocupants completion:(QBChatDialogResultBlock)completion;

/**
 Create private chat dialog
 
 @param opponent - oponent.
 @result QBChatDialogResult
 */
- (void)createPrivateChatDialogWithOpponent:(QBUUser *)opponent completion:(QBChatDialogResultBlock)completion;
- (void)createPrivateChatDialogIfNeededWithOpponent:(QBUUser *)opponent completion:(void(^)(QBChatDialog *chatDialog))completion;
/**
 Leave user from chat dialog
 
 @param userID - user identifier
 @param chatDialog - chat dialog
 @result QBChatDialogResult
 */
- (void)leaveWithUserId:(NSUInteger)userID fromChatDialog:(QBChatDialog *)chatDialog completion:(QBChatDialogResultBlock)completion;

/**
 Join users to chat dialog
 
 @param occupantsIDs - Array of QBUUser in chat.
 @result QBChatDialogResult
 */
- (void)joinOccupants:(NSArray *)occupants toChatDialog:(QBChatDialog *)chatDialog completion:(QBChatDialogResultBlock)completion;

/**
 Join new users to chat
 
 @param dialogName
 @result QBChatDialogResult
 */
- (void)changeChatName:(NSString *)dialogName forChatDialog:(QBChatDialog *)chatDialog completion:(QBChatDialogResultBlock)completion;

- (NSUInteger)occupantIDForPrivateChatDialog:(QBChatDialog *)chatDialog;
- (QBChatRoom *)chatRoomWithRoomJID:(NSString *)roomJID;

@end


@interface QMApi (Users)

@property (strong, nonatomic, readonly) NSArray *friends;

- (NSArray *)idsWithUsers:(NSArray *)users;
- (void)addUser:(QBUUser *)user;
- (void)addUsers:(NSArray *)users;
- (QBUUser *)userWithID:(NSUInteger)userID;
- (QBContactListItem *)contactItemWithUserID:(NSUInteger)userID;

/**
 Add user to contact list request
 
 @param userID ID of user which you would like to add to contact list
 @return*/
- (BOOL)addUserToContactListRequest:(NSUInteger)userID;

/**
 Remove user from contact list
 
 @param userID ID of user which you would like to remove from contact list
 @return YES if the request was sent successfully. If not - see log.
 */
- (BOOL)removeUserFromContactListWithUserID:(NSUInteger)userID;

/**
 Confirm add to contact list request
 
 @param userID ID of user from which you would like to confirm add to contact request
 @return YES if the request was sent successfully. If not - see log.
 */
- (BOOL)confirmAddContactRequest:(NSUInteger)userID;

- (BOOL)rejectAddContactRequest:(NSUInteger)userID;

/**
 Retrieve Friends from contact list if needed;
 */
- (void)retrieveFriendsIfNeeded:(void(^)(BOOL updated))completion;

/**
 Retrieve users from chat Dialog (occupantIDs) if needed;
 */
- (void)retrieveUsersForChatDialog:(QBChatDialog *)chatDialog completion:(void(^)(BOOL updated))completion;

/**
 Retrieve users with ids (idsToFetch - must be NSString's)
 */
- (void)retrieveUsersWithIDs:(NSArray *)idsToFetch completion:(void(^)(BOOL updated))completion;

@end

/**
 Facebook interface
 */
@interface QMApi (Facebook)

- (void)fbLogout;
- (NSURL *)fbUserImageURLWithUserID:(NSString *)userID;
- (void)fbFriends:(void(^)(NSArray *fbFriends))completion;
- (void)fbInviteUsersWithIDs:(NSArray *)ids copmpletion:(void(^)(NSError *error))completion;

@end

/** 
 Calls interface 
 */
@interface QMApi (Calls)

- (void)callUser:(NSUInteger)userID opponentView:(QBVideoView *)opponentView conferenceType:(QBVideoChatConferenceType)conferenceType;

- (void)acceptCallFromUser:(NSUInteger)userID opponentView:(QBVideoView *)opponentView;
- (void)rejectCallFromUser:(NSUInteger)userID opponentView:(QBVideoView *)opponentView;

- (void)finishCall;

@end