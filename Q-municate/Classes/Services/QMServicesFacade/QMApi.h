//
//  QMApi.h
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 9/24/15.
//  Copyright © 2015 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

@class QMSettingsManager;
@class QMAVCallManager;
@class QMContentService;
@class Reachability;

@protocol FBSDKAppInviteDialogDelegate;

typedef NS_ENUM(NSInteger, QMAccountType);

/*** Completion blocks ***/
typedef void(^QBDialogsPagedResponseBlock)(QBResponse *response, NSArray *dialogObjects, NSSet *dialogsUsersIDs, QBResponsePage *page);
typedef void(^QBChatDialogResponseBlock)(QBResponse *response, QBChatDialog *updatedDialog);

/**
 *  Q-municate services manager
 */
@interface QMApi : NSObject <QMServiceManagerProtocol,
                             QMChatServiceCacheDataSource,
                             QMChatServiceDelegate,
                             QMChatConnectionDelegate,
                             QMContactListServiceDelegate,
                             QMContactListServiceCacheDataSource>

/**
 *  REST authentication service.
 */
@property (strong, nonatomic, readonly) QMAuthService* authService;

/**
 *  Chat service.
 */
@property (strong, nonatomic, readonly) QMChatService* chatService;

/**
 *  Contact list service.
 */
@property (strong, nonatomic, readonly) QMContactListService* contactListService;

/**
 *  Settings manager.
 */
@property (strong, nonatomic, readonly) QMSettingsManager *settingsManager;

/**
 *  Audio video call manager service.
 */
@property (strong, nonatomic, readonly) QMAVCallManager *avCallManager;

/**
 *  Custom content service.
 */
@property (strong, nonatomic, readonly) QMContentService *contentService;

/**
 *  Reachability manager.
 */
@property (strong, nonatomic, readonly) Reachability *internetConnection;

/**
 *  Current user.
 */
@property (strong, nonatomic, readonly) QBUUser *currentUser;

/**
 *  Current device token for push notifications.
 */
@property (nonatomic, strong) NSData *deviceToken;

/**
 *  Push notification dictionary
 */
@property (nonatomic, strong) NSDictionary *pushNotification;

/**
 *  QMApi class shared instance
 */
+ (instancetype)instance;

/**
 *  Fetching all dialogs history and users that are involved in it
 */
- (void)fetchAllHistory:(void(^)(void))completion;

/**
 *  Handling response if error. Only available for responses with status value False.
 *
 *  @param response     QBResponse instance to handle
 */
- (void)handleErrorResponse:(QBResponse *)response;

/**
 *  @return Internet connection status
 */
- (BOOL)isInternetConnected;

/**
 *  Application state changing handling
 */
- (void)applicationDidBecomeActive:(void(^)(BOOL success))completion;
- (void)applicationWillResignActive;

/**
 *  Handling push notification and opening dialog from push.
 *
 *  @param norification     dictionary instance with norification params
 *  @param completionBlock  completion block with status
 */
- (void)openChatPageForPushNotification:(NSDictionary *)notification completion:(void(^)(BOOL completed))completionBlock;

@end


/**
 *  Auth category of QMApi class
 */
@interface QMApi (Auth)

/**
 *  Auto login if user is not authorized
 *
 *  @param completion   completion block with success status
 */
- (void)autoLogin:(void(^)(BOOL success))completion;

/**
 *  Set auto login with account type.
 *
 *  @param autologin    boolean value that to setup auto login if YES
 *  @param accountType  QMAccountType value that represents account type of current account
 */
- (void)setAutoLogin:(BOOL)autologin withAccountType:(QMAccountType)accountType;

/**
 *  Signing up and loggin in user.
 *
 *  @param user         QBUUser instance to handle
 *  @param rememberMe   boolean value to call auto login every time app is opening if YES
 *  @param completion   completion block with success status
 */
- (void)signUpAndLoginWithUser:(QBUUser *)user rememberMe:(BOOL)rememberMe completion:(void(^)(BOOL success))completion;

/**
 *  Signing up and loggin in with facebook.
 *
 *  @param completion   completion block with success status
 */
- (void)singUpAndLoginWithFacebook:(void(^)(BOOL success))completion;

/**
 *  Loggin user in with email and password.
 *
 *  @param email        user email
 *  @param password     user password
 *  @param rememberMe   boolean value to call auto login every time app is opening if YES
 *  @param completion   completion block with success status
 */
- (void)loginWithEmail:(NSString *)email password:(NSString *)password rememberMe:(BOOL)rememberMe completion:(void(^)(BOOL success))completion;

/**
 *  Loggin user in with facebook.
 *
 *  @param completion   completion block with success status
 */
- (void)loginWithFacebook:(void(^)(BOOL success))completion;

/**
 *  Loggin user out.
 *
 *  @param completion   completion block with success status
 */
- (void)logout:(void(^)(BOOL success))completion;

/**
 *  Resetting user's password.
 *
 *  @param email        current user email to send reset password link
 *  @param completion   completion block with success status
 */
- (void)resetUserPassordWithEmail:(NSString *)email completion:(void(^)(BOOL success))completion;

/**
 *  Push notification subscription handling
 */
- (void)subscribeToPushNotificationsForceSettings:(BOOL)force complete:(void(^)(BOOL success))complete;
- (void)unSubscribeToPushNotifications:(void(^)(BOOL success))complete;

@end


/**
 *  Notifications category of QMApi class
 */
@interface QMApi (Notifications)

/**
 *  Contact request notifications handling
 */
- (void)sendContactRequestSendNotificationToUser:(QBUUser *)user completion:(void(^)(NSError *error, QBChatMessage *notification))completionBlock;
- (void)sendContactRequestDeleteNotificationToUser:(QBUUser *)user completion:(void(^)(NSError *error, QBChatMessage *notification))completionBlock;

@end


/**
 *  Chat category of QMApi class
 */
@interface QMApi (Chat)

/*** Messages ***/

/**
 *  Loggin in to chat.
 *
 *  @param block    completion block with success status
 */
- (void)loginChat:(void(^)(BOOL success))block;

/**
 *  Loggin out from chat.
 */
- (void)logoutFromChat;

/**
 *  Fetching messages for active chat if needed.
 *
 *  @param block    completion block with YES boolean value if fetching was needed
 */
- (void)fetchMessagesForActiveChatIfNeededWithCompletion:(void(^)(BOOL fetchWasNeeded))block;


/*** Chat Dialogs ***/

/**
 *  All dialogs in history.
 *
 *  @return     all unsorted dialogs from history
 */
- (NSArray *)dialogHistory;

/**
 *  All users that are involved in all dialogs from history.
 *
 *  @return all unsorted users that are involved in all dialogs from history.
 */
- (NSArray *)allOccupantIDsFromDialogsHistory;

/**
 *  Chat dialog with requested ID.
 *
 *  @param dialogID id of dialog to return
 *
 *  @return QBChatDialog instance of requested dialog ID
 */
- (QBChatDialog *)chatDialogWithID:(NSString *)dialogID;

/**
 *  Fetching all dialogs for current user.
 *
 *  @param completion   completion block
 */
- (void)fetchAllDialogs:(void(^)(void))completion;

/**
 *  Fetching all dialogs with last activity from requested date.
 *
 *  @param date         date to fetch dialogs with last activity from
 *  @param completion   completion with QBDialogsPagedResponseBlock block
 */
- (void)fetchDialogsWithLastActivityFromDate:(NSDate *)date completion:(QBDialogsPagedResponseBlock)completion;

/**
 *  Fetching dialog with requested ID and retrieving its users.
 *
 *  @param dialogID     id of dialog to return
 *  @param completion   completion block with QBChatDialog instance with requested id
 */
- (void)fetchChatDialogWithID:(NSString *)dialogID completion:(void(^)(QBChatDialog *chatDialog))completion;

/**
 *  Deleting dialog.
 *
 *  @param dialog       QBChatDialog instance to delete
 *  @param completion   completion block with success status
 */
- (void)deleteChatDialog:(QBChatDialog *)dialog completion:(void(^)(BOOL success))completionHandler;

/**
 *  Creating group chat.
 *
 *  @param name         name of new group chat
 *  @param occupants    occupants to add to new group dialogs
 *  @oaram completion   completion block with created QBChatDialog instance
 */
- (void)createGroupChatDialogWithName:(NSString *)name occupants:(NSArray *)occupants completion:(void(^)(QBChatDialog *chatDialog))completion;

/**
 *  Creating private dialog.
 *
 *  @param opponent     QBUUser instance of user to chat with
 *  @param completion   completion block with created QBChatDialog instance
 */
- (void)createPrivateChatDialogIfNeededWithOpponent:(QBUUser *)opponent completion:(void(^)(QBChatDialog *chatDialog))completion;

/**
 *  Leaving group chat.
 *
 *  @param chatDialog   QBChatDialog instance to leave
 *  @param completion   completion with QBChatDialogResponseBlock block
 */
- (void)leaveChatDialog:(QBChatDialog *)chatDialog completion:(QBChatDialogResponseBlock)completion;

/**
 *  Adding users to group chat.
 *
 *  @param occupants    array of QBUUser instances of users to add to group chat
 *  @param chatDialog   QBChatDialog instance of group chat to add users to
 *  @param completion   completion with QBChatDialogResponseBlock block
 */
- (void)joinOccupants:(NSArray *)occupants toChatDialog:(QBChatDialog *)chatDialog completion:(QBChatDialogResponseBlock)completion;

/**
 *  Join all group chats that are exist in history.
 */
- (void)joinGroupDialogs;

/**
 *  Changing group chat name.
 *
 *  @param dialogName   new group chat name
 *  @param chatDialog   QBChatDialog instance of chat to update
 *  @param completion   completion with QBChatDialogResponseBlock block
 */
- (void)changeChatName:(NSString *)dialogName forChatDialog:(QBChatDialog *)chatDialog completion:(QBChatDialogResponseBlock)completion;

/**
 *  Changing group chat avatar.
 *
 *  @param avatar       UIImage instance of avatar to update
 *  @param chatDialog   QBChatDialog instance of dialog to update
 *  @param completion   completion with QBChatDialogResponseBlock block
 */
- (void)changeAvatar:(UIImage *)avatar forChatDialog:(QBChatDialog *)chatDialog completion:(QBChatDialogResponseBlock)completion;

/**
 *  Opponent id in private dialog.
 *
 *  @param chatDialog   QBChatDialog instance of private dialog
 *
 *  @return ID of opponent in requested private dialog
 */
- (NSUInteger)occupantIDForPrivateChatDialog:(QBChatDialog *)chatDialog;

@end


/**
 *  Users category of QMApi class
 */
@interface QMApi (Users)

/* Array of friends represented with QBUUser instances */
@property (strong, nonatomic, readonly) NSArray *friends;

/* Array of contacts only represented with QBUUser instances */
@property (strong, nonatomic, readonly) NSArray *contactsOnly;

/**
 *  Checking if friends with user.
 *
 *  @param user QBUUser instance of user to check
 *
 *  @return boolean value YES if user is in friend list
 */
- (BOOL)isFriend:(QBUUser *)user;

/**
 *  Users with ids.
 *
 *  @param ids  array of NSNumber user ids
 *
 *  @return array of QBUUser instances with users
 */
- (NSArray *)usersWithIDs:(NSArray *)ids;

/**
 *  Ids of users.
 *
 *  @param users    array of QBUUser instances of users
 *
 *  @return array of users NSNumber ids
 */
- (NSArray *)idsWithUsers:(NSArray *)users;

/**
 *  User with id.
 *
 *  @param userID   id of user to return
 *
 *  @return QBUUser instance with user or nil if not found
 */
- (QBUUser *)userWithID:(NSUInteger)userID;

/**
 *  Contact item with user id.
 *
 *  @param userID   id of user
 *
 *  @return QBContactListItem instance of requested user
 */
- (QBContactListItem *)contactItemWithUserID:(NSUInteger)userID;

/**
 *  Is contact request with user.
 *
 *  @param userID   id of user
 *
 *  @return boolean value YES if user is in contact request status
 */
- (BOOL)isContactRequestUserWithID:(NSInteger)userID;

/**
 *  Is user in pending list.
 *
 *  @param userID   id of user
 *
 *  @return boolean value YES if user contact status is Pending
 */
- (BOOL)userIDIsInPendingList:(NSUInteger)userID;

/**
 *  Import facebook friends from quickblox database.
 */
- (void)importFriendsFromFacebook;

/**
 *  Import friends from Address book which exists in quickblox database.
 *
 *  @param completionBlock  completion block with success status and error if necessary
 */
- (void)importFriendsFromAddressBookWithCompletion:(void(^)(BOOL succeded, NSError *error))completionBlock;

/**
 *  Add user to contact list request.
 *
 *  @param user         QBUUser instance of user which you would like to add to contact list
 *  @param completion   completion block with success status and QBChatMessage instance of notification message
 */
- (void)addUserToContactList:(QBUUser *)user completion:(void(^)(BOOL success, QBChatMessage *notification))completion;

/**
 *  Remove user from contact list.
 *
 *  @param userID       ID of user which you would like to remove from contact list
 *  @param completion   completion block with success status and QBChatMessage instance of notification message
 */
- (void)removeUserFromContactList:(QBUUser *)user completion:(void(^)(BOOL success, QBChatMessage *notification))completion;

/**
 *  Confirm add to contact list request.
 *
 *  @param userID       ID of user from which you would like to confirm add to contact request
 *  @param completion   completion block with success status
 */
- (void)confirmAddContactRequest:(QBUUser *)user completion:(void(^)(BOOL success))completion;

/**
 *  Reject add to contact list request.
 *
 *  @param userID       ID of user from which you would like to reject add to contact request
 *  @param completion   completion block with success status
 */
- (void)rejectAddContactRequest:(QBUUser *)user completion:(void(^)(BOOL success))completion;

/**
 *  Retrieving user if needed.
 *
 *  @param userID       id of user to retrieve
 *  @param completion   completion block with boolean value YES if retrieve was needed
 */
- (void)retriveIfNeededUserWithID:(NSUInteger)userID completion:(void(^)(BOOL retrieveWasNeeded))completionBlock;

/**
 *  Retrieving users if needed.
 *
 *  @param userIDs      array of users ids to retrieve
 *  @param completion   completion block with boolean value YES if retrieve was needed
 */
- (void)retriveIfNeededUsersWithIDs:(NSArray *)usersIDs completion:(void (^)(BOOL retrieveWasNeeded))completionBlock;

/**
 *  Updating current user with params and image.
 *
 *  @param updateParams     QBUpdateUserParameters instance of parameters to update
 *  @param image            UIImage instance of image to update (can be nil)
 *  @param progress         progress with QMContentProgressBlock block
 *  @param completion       completion block with success status
 */
- (void)updateCurrentUser:(QBUpdateUserParameters *)updateParams image:(UIImage *)image progress:(QMContentProgressBlock)progress completion:(void (^)(BOOL success))completion;

/**
 *  Updating current user with params and image url.
 *
 *  @param updateParams     QBUpdateUserParameters instance of parameters to update
 *  @param imageUrl         NSURL instance of image url to update
 *  @param progress         progress with QMContentProgressBlock block
 *  @param completion       completion block with success status
 */
- (void)updateCurrentUser:(QBUpdateUserParameters *)params imageUrl:(NSURL *)imageUrl progress:(QMContentProgressBlock)progress completion:(void (^)(BOOL success))completion;

/**
 *  Changing password for current user.
 *
 *  @param updateParams     QBUpdateUserParameters instance of parameters with old and new passwords
 *  @param completion       completion block with success status
 */
- (void)changePasswordForCurrentUser:(QBUpdateUserParameters *)updateParams completion:(void(^)(BOOL success))completion;

@end


/**
 *  Facebook category of QMApi class
 */
@interface QMApi (Facebook)

/**
 *  Logout from facebook
 */
- (void)fbLogout;

/**
 *  Invite friends from facebook.
 *
 *  @param controller   UIViewController instance of controller to present dialog in
 *  @param delegate     delegate protocol
 */
- (void)fbInviteDialogWithDelegate:(id<FBSDKAppInviteDialogDelegate>)delegate;

/**
 *  Facebook user image url.
 *  
 *  @param userID   facebook user id
 *  
 *  @return NSURL instance of facebook user image url
 */
- (NSURL *)fbUserImageURLWithUserID:(NSString *)userID;

/**
 *  Facebook friends.
 *
 *  @param completion   completion block with array of facebook friends
 */
- (void)fbFriends:(void(^)(NSArray *fbFriends))completion;

@end


/**
 *  Calls categoty of QMApi class
 */
@interface QMApi (Calls)

/* Call to users with conference type. */
- (void)callToUser:(NSNumber *)userID conferenceType:(enum QBConferenceType)conferenceType;
/* Call to users with conference type and send push notification */
- (void)callToUser:(NSNumber *)userID conferenceType:(enum QBConferenceType)conferenceType sendPushNotificationIfUserIsOffline:(BOOL)pushEnabled;
/* Accept call */
- (void)acceptCall;
/* Reject call */
- (void)rejectCall;
/* End call */
- (void)finishCall;

@end


/**
 *  Permissions category of QMApi class
 */
@interface QMApi (Permissions)

/**
 *  Q-municate permission requests
 */
- (void)requestPermissionToCameraWithCompletion:(void(^)(BOOL authorized))completion;
- (void)requestPermissionToMicrophoneWithCompletion:(void(^)(BOOL granted))completion;

@end


/**
 *  CurrentUser category of NSObject class
 */
@interface NSObject(CurrentUser)

/* Current user instance */
@property (strong, nonatomic) QBUUser *currentUser;

@end
