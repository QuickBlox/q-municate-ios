//
//  QMServicesFacade.h
//  Qmunicate
//
//  Created by Andrey Ivanov on 01.07.14.
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
@class QMContentService;

@interface QMApi : NSObject

@property (strong, nonatomic, readonly) QMAuthService *authService;
@property (strong, nonatomic, readonly) QMSettingsManager *settingsManager;
@property (strong, nonatomic, readonly) QMFacebookService *facebookService;
@property (strong, nonatomic, readonly) QMUsersService *usersService;
@property (strong, nonatomic, readonly) QMChatService *chatService;
@property (strong, nonatomic, readonly) QMAVCallService *avCallService;
@property (strong, nonatomic, readonly) QMChatDialogsService *chatDialogsService;
@property (strong, nonatomic, readonly) QMMessagesService *messagesService;
@property (strong, nonatomic, readonly) QMChatReceiver *responceService;
@property (strong, nonatomic, readonly) QMContentService *contentService;
@property (strong, atomic) QBUUser *currentUser;

+ (instancetype)instance;

- (void)fetchAllHistory:(void(^)(void))completion;
- (BOOL)checkResult:(Result *)result;

- (void)startServices;
- (void)stopServices;


@end

@interface QMApi (Auth)

/**
 User LogIn with facebook
 
 Type of Result - QBUUserLogInResult
 @return completion stastus
 */

- (void)setAutoLogin:(BOOL)autologin;
- (void)loginWithFacebook:(void(^)(BOOL success))completion;
- (void)loginWithUser:(QBUUser *)user completion:(void(^)(BOOL success))complition;
- (void)signUpAndLoginWithUser:(QBUUser *)user completion:(void(^)(BOOL success))completion;
/*logout*/
- (void)resetUserPassordWithEmail:(NSString *)email completion:(void(^)(BOOL success))completion;
- (void)logout:(void(^)(BOOL success))success;
- (void)applicationDidBecomeActive:(void(^)(BOOL success))completion;
- (void)applicationWillResignActive;

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
- (QBChatMessage *)sendAttachment:(NSString *)attachmentUrl toDialog:(QBChatDialog *)dialog;

@end

@interface QMApi (ChatDialogs)

- (NSArray *)dialogHistory;
- (NSArray *)allOccupantIDsFromDialogsHistory;
- (QBChatDialog *)chatDialogWithID:(NSString *)dialogID;

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

- (NSArray *)usersWithIDs:(NSArray *)ids;
- (NSArray *)idsWithUsers:(NSArray *)users;
- (QBUUser *)userWithID:(NSUInteger)userID;
- (QBContactListItem *)contactItemWithUserID:(NSUInteger)userID;
- (NSArray *)idsFromContactListItems;

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

/*UPDATE USER*/
- (void)updateUser:(QBUUser *)user completion:(void(^)(BOOL success))completion;

/**
 */
- (void)updateUser:(QBUUser *)user image:(UIImage *)image progress:(QMContentProgressBlock)progress completion:(void (^)(BOOL success))completion;
/**
 
 */
- (void)updateUser:(QBUUser *)user imageUrl:(NSURL *)imageUrl progress:(QMContentProgressBlock)progress completion:(void (^)(BOOL success))completion;

/**
 */
- (void)changePasswordForCurrentUser:(QBUUser *)currentUser completion:(void(^)(BOOL success))completion;

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

- (void)callUser:(NSUInteger)userID opponentView:(QBVideoView *)opponentView conferenceType:(enum QBVideoChatConferenceType)conferenceType;
- (void)acceptCallFromUser:(NSUInteger)userID opponentView:(QBVideoView *)opponentView;
- (void)rejectCallFromUser:(NSUInteger)userID opponentView:(QBVideoView *)opponentView;
- (void)finishCall;

@end