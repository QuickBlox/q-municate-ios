//
//  QMServicesFacade.h
//  Qmunicate
//
//  Created by Andrey Ivanov on 01.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QMUsersUtils.h"

@class QMAuthService;
@class QMSettingsManager;
@class QMFacebookService;
@class QMUsersService;
@class QMChatDialogsService;
@class QMAVCallService;
@class QMMessagesService;
@class QMChatReceiver;
@class QMContentService;
@class Reachability;

typedef NS_ENUM(NSUInteger, QMAccountType);

@interface QMApi : NSObject

@property (strong, nonatomic, readonly) QMAuthService *authService;
@property (strong, nonatomic, readonly) QMSettingsManager *settingsManager;
@property (strong, nonatomic, readonly) QMUsersService *usersService;
@property (strong, nonatomic, readonly) QMAVCallService *avCallService;
@property (strong, nonatomic, readonly) QMChatDialogsService *chatDialogsService;
@property (strong, nonatomic, readonly) QMMessagesService *messagesService;
@property (strong, nonatomic, readonly) QMChatReceiver *responceService;
@property (strong, nonatomic, readonly) QMContentService *contentService;
@property (strong, nonatomic, readonly) Reachability *internetConnection;

@property (strong, nonatomic, readonly) QBUUser *currentUser;

@property (nonatomic, copy) UIApplicationDeviceTokenBlock subscriptionBlock;

+ (instancetype)instance;

- (BOOL)checkResult:(Result *)result;

- (void)startServices;
- (void)stopServices;

- (void)applicationDidBecomeActive:(void(^)(BOOL success))completion;
- (void)applicationWillResignActive;
- (void)openChatPageForPushNotification:(NSDictionary *)notification;

- (void)fetchAllHistory:(void(^)(void))completion;

@end

@interface QMApi (Auth)

- (void)autoLogin:(void(^)(BOOL success))completion;

- (void)createSessionWithBlock:(void(^)(BOOL success))completion;
- (void)setAutoLogin:(BOOL)autologin withAccountType:(QMAccountType)accountType;

- (void)signUpAndLoginWithUser:(QBUUser *)user rememberMe:(BOOL)rememberMe completion:(void(^)(BOOL success))completion;
- (void)singUpAndLoginWithFacebook:(void(^)(BOOL success))completion;
/**
 User LogIn with email and password
 
 Type of Result - QBUUserLogInResult
 @return completion stastus
 */

- (void)loginWithEmail:(NSString *)email password:(NSString *)password rememberMe:(BOOL)rememberMe completion:(void(^)(BOOL success))completion;

/**
 User LogIn with facebook
 
 Type of Result - QBUUserLogInResult
 @return completion stastus
 */
- (void)loginWithFacebook:(void(^)(BOOL success))completion;
- (void)logout:(void(^)(BOOL success))completion;

/**
 Reset user password wiht email
 */
- (void)resetUserPassordWithEmail:(NSString *)email completion:(void(^)(BOOL success))completion;
- (void)subscribeToPushNotificationsForceSettings:(BOOL)force complete:(void(^)(BOOL success))complete;
- (void)unSubscribeToPushNotifications:(void(^)(BOOL success))complete;

@end

@interface QMApi (Messages)

@property (nonatomic, strong) NSDictionary *pushNotification;

- (void)loginChat:(QBChatResultBlock)block;
- (void)logoutFromChat;
/**
 */
- (void)fetchMessageWithDialog:(QBChatDialog *)chatDialog complete:(void(^)(BOOL success))complete;


/** 
 *
 */
- (void)fetchMessagesForActiveChatIfNeededWithCompletion:(void(^)(BOOL fetchWasNeeded))block;

/**
 */
- (NSArray *)messagesHistoryWithDialog:(QBChatDialog *)chatDialog;
/**
 if ok return QBChatMessage , else nil
 */

- (void)sendText:(NSString *)text toDialog:(QBChatDialog *)dialog completion:(void(^)(QBChatMessage * message))completion;
- (void)sendAttachment:(QBCBlob *)attachment toDialog:(QBChatDialog *)dialog completion:(void(^)(QBChatMessage * message))completion;

- (void)fireEnqueuedMessageForChatRoomWithJID:(NSString *)roomJID;

@end


@interface QMApi (Notifications)

- (void)sendContactRequestSendNotificationToUser:(QBUUser *)user completion:(void(^)(NSError *error, QBChatMessage *notification))completionBlock;
- (void)sendContactRequestConfirmNotificationToUser:(QBUUser *)user completion:(void(^)(NSError *error, QBChatMessage *notification))completionBlock;
- (void)sendContactRequestRejectNotificationToUser:(QBUUser *)user completion:(void(^)(NSError *error, QBChatMessage *notification))completionBlock;
- (void)sendContactRequestDeleteNotificationToUser:(QBUUser *)user completion:(void(^)(NSError *error, QBChatMessage *notification))completionBlock;

- (void)sendGroupChatDialogDidCreateNotification:(QBChatMessage *)notification toChatDialog:(QBChatDialog *)chatDialog persistent:(BOOL)persistent completionBlock:(void(^)(QBChatMessage *))completion;
- (void)sendGroupChatDialogDidUpdateNotification:(QBChatMessage *)notification toChatDialog:(QBChatDialog *)chatDialog completionBlock:(void(^)(QBChatMessage *))completion;

@end


@interface QMApi (ChatDialogs)

/**
 return cached dialogs
 
 @result array QBChatDialg's
 */
- (NSArray *)dialogHistory;
/**/
- (NSArray *)allOccupantIDsFromDialogsHistory;
- (QBChatDialog *)chatDialogWithID:(NSString *)dialogID;

/**
 Get all dialogs for current user
 */
- (void)fetchAllDialogs:(void(^)(void))completion;

/**
 * Returns updated dialogs and updates exists
 */
- (void)fetchDialogsWithLastActivityFromDate:(NSDate *)date completion:(QBDialogsPagedResultBlock)completion;

/**
 *
 */
- (void)deleteChatDialog:(QBChatDialog *)dialog completion:(void(^)(BOOL success))completionHandler;

/**
 Create group chat dialog
 
 @param name - Group chat name.
 @param ocupants - Array of QBUUser in chat.
 @result QBChatDialogResult
 */
- (void)createGroupChatDialogWithName:(NSString *)name occupants:(NSArray *)occupants completion:(QBChatDialogResultBlock)completion;

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
- (void)leaveChatDialog:(QBChatDialog *)chatDialog completion:(QBChatDialogResultBlock)completion;

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

- (void)changeAvatar:(UIImage *)avatar forChatDialog:(QBChatDialog *)chatDialog completion:(QBChatDialogResultBlock)completion;

- (NSUInteger)occupantIDForPrivateChatDialog:(QBChatDialog *)chatDialog;

@end


@interface QMApi (Users)

@property (strong, nonatomic, readonly) NSArray *friends;
@property (strong, nonatomic, readonly) NSArray *contactsOnly;
@property (strong, nonatomic, readonly) NSArray *contactRequestUsers;

- (BOOL)isFriendForChatDialog:(QBChatDialog *)chatDialog;
- (BOOL)isFriend:(QBUUser *)user;

- (NSArray *)usersWithIDs:(NSArray *)ids;
- (NSArray *)idsWithUsers:(NSArray *)users;
- (QBUUser *)userWithID:(NSUInteger)userID;
- (QBContactListItem *)contactItemWithUserID:(NSUInteger)userID;


/**
 Opponent for private chat dialog. Only for private chat dialogs.
 */
- (QBUUser *)userForContactRequestWithPrivateChatDialog:(QBChatDialog *)chatDialog;

/** 
 Import facebook friends from quickblox database.
 */
- (void)importFriendsFromFacebook;

/**
 Import friends from Address book which exists in quickblox database.
 */
- (void)importFriendsFromAddressBook;

/**
 Add user to contact list request
 
 @param user of user which you would like to add to contact list
 @return*/
- (void)addUserToContactList:(QBUUser *)user completion:(void(^)(BOOL success, QBChatMessage *notification))completion;

/**
 Remove user from contact list
 
 @param userID ID of user which you would like to remove from contact list
 @return YES if the request was sent successfully. If not - see log.
 */
- (void)removeUserFromContactList:(QBUUser *)user completion:(void(^)(BOOL success, QBChatMessage *notification))completion;

/**
 Confirm add to contact list request
 
 @param userID ID of user from which you would like to confirm add to contact request
 @return YES if the request was sent successfully. If not - see log.
 */
- (void)confirmAddContactRequest:(QBUUser *)user completion:(void(^)(BOOL success, QBChatMessage *notification))completion;

/**
 Reject add to contact list request
 
 @param userID ID of user from which you would like to reject add to contact request
 @return YES if the request was sent successfully. If not - see log.
 */
- (void)rejectAddContactRequest:(QBUUser *)user completion:(void(^)(BOOL success, QBChatMessage *notification))completion;

/**
 Retrieving user if needed.
 */
- (void)retriveIfNeededUserWithID:(NSUInteger)userID completion:(void(^)(BOOL retrieveWasNeeded))completionBlock;
- (void)retriveIfNeededUsersWithIDs:(NSArray *)usersIDs completion:(void (^)(BOOL retrieveWasNeeded))completionBlock;



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
- (void)fbIniviteDialogWithCompletion:(void(^)(BOOL success))completion;
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

@interface NSObject(CurrentUser)

@property (strong, nonatomic) QBUUser *currentUser;

@end