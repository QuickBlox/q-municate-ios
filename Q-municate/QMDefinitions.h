//
//  QMDefinitions.h
//  Q-municate
//
//  Created by Igor Alefirenko on 14/02/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#ifndef Q_municate_Definitions_h
#define Q_municate_Definitions_h

//*********** Settings Cell Row Names **********************
#define QMSettingsNormalCellRowProfile              0
#define QMSettingsNormalCellRowPushNotifications    1
#define QMSettingsNormalCellRowChangePassword       2
#define QMSettingsNormalCellRowLogOut               3
#define QMSettingsNormalCellRowVersion              4
#define QMSettingsCustomCellRowLogOut               2
#define QMSettingsCustomCellRowVersion              3

//*****************  Color  ********************************
#define kHintColor [UIColor colorWithRed:187/255.0f green:192/255.0f blue:202/255.0f alpha:1.0f]

//****************** Enums *********************************
typedef enum {
    SettingsViewControllerModeNormal,
    SettingsViewControllerModeCustom
} SettingsViewControllerMode;

typedef NS_ENUM(NSUInteger, QMLogLevel)
{
    QMLogLevelNothing,
    QMLogLevelError,
    QMLogLevelInfo,
    QMLogLevelVerbose
};

typedef NS_ENUM(NSUInteger, QMMembersUpdateState) {
    QMMembersUpdateStateNone,
    QMMembersUpdateStateAdding,
    QMMembersUpdateStateRemoving
};

//****************** Blocks *********************************
typedef void (^QBResultBlock)(Result *result);
typedef void (^QBSessionCreationBlock)(BOOL success, NSError *error);
typedef void (^QBAuthResultBlock)(QBUUser *user, BOOL success, NSError *error);
typedef void (^QBChatResultBlock)(BOOL success);
typedef void (^QBChatDialogResultBlock)(QBChatDialog *dialog, NSError *error);
typedef void (^QBChatRoomResultBlock)(QBChatRoom *chatRoom, NSError *error);
typedef void (^QBChatDialogHistoryBlock)(NSMutableArray *chatDialogHistoryArray, NSError *error);
typedef void (^QBContactListBlock)(id object);
typedef void (^QBContentBlock)(QBCBlob *blob);
typedef void (^QBDataBlock)(id data);
typedef void (^QBUsersBlock)(NSArray *users);

typedef void(^QBPagedUsersBlock)(NSArray *users, BOOL success, NSError *error);
typedef void(^FBCompletionBlock)(BOOL success, NSError *error);

typedef void(^AddressBookResult)(NSArray *contacts, BOOL success, NSError *error);


//************** Segue Identifiers *************************
static NSString *const kTabBarSegueIdnetifier         = @"TabBarSegue";
static NSString *const kSplashSegueIdentifier         = @"SplashSegue";
static NSString *const kWelcomeScreenSegueIdentifier  = @"WelcomeScreenSegue";
static NSString *const kSignUpSegueIdentifier         = @"SignUpSegue";
static NSString *const kLogInSegueSegueIdentifier     = @"LogInSegue";
static NSString *const kDetailsSegueIdentifier        = @"DetailsSegue";
static NSString *const kVideoCallSegueIdentifier      = @"VideoCallSegue";
static NSString *const kAudioCallSegueIdentifier      = @"AudioCallSegue";
static NSString *const kStartCallSegueIdentifier      = @"StartCallSegue";
static NSString *const kChatViewSegueIdentifier       = @"ChatViewSegue";
static NSString *const kIncomingCallIdentifier        = @"IncomingCallIdentifier";
static NSString *const kProfileSegueIdentifier        = @"ProfileSegue";
static NSString *const kCreateNewChatSegueIdentifier  = @"CreateNewChatSegue";
static NSString *const kContentPreviewSegueIdentifier = @"ContentPreviewIdentifier";
static NSString *const kGroupDetailsSegueIdentifier   = @"GroupDetailsSegue";

//****************** Cell Identifiers  ********************
static NSString *const kSettingsVCCellIdentifier                = @"SettingsCellIdentifier";

static NSString *const kChatUploadingAttachmentCellIdentitier   = @"UploadingAttachIdentifier";
static NSString *const kChatInvitationCellIdentifier            = @"InvitationCell";
static NSString *const kChatPrivateContentCellIdentifier        = @"PrivateContentCell";
static NSString *const kChatPrivateMessageCellIdentifier        = @"PrivateChatCell";
static NSString *const kChatGroupContentCellIdentifier          = @"GroupContentCell";

//**************** Setting Cell Titles ********************
static NSString *const kSettingsCellTitleProfile            = @"Profile";
static NSString *const kSettingsCellTitlePushNotifications  = @"Push Notifications";
static NSString *const kSettingsCellTitleChangePassword     = @"Change Password";
static NSString *const kSettingsCellBundleVersion           = @"CFBundleVersion";

//****************** Notifications  ***********************
static NSString *const kFriendsReloadedNotification     = @"Friends reloaded";
static NSString *const kAllUsersLoadedNotification    = @"All users loaded";
static NSString *const kLoggedInNotification          = @"LoggedInNotification";

static NSString *const kChatDidNotSendMessage			= @"kChatDidNotSendMessage";
static NSString *const kChatDidReceiveMessage			= @"kChatDidReceiveMessage";
static NSString *const kChatDidFailWithError			= @"kChatDidFailWithError";
static NSString *const kChatDidSendMessage				= @"kChatDidSendMessage";
static NSString *const kChatRoomDidEnterNotification	= @"ChatRoomDidEnter";
static NSString *const kChatRoomDidReceiveMessageNotification = @"ChatRoomDidReceiveMessage";
static NSString *const kChatRoomDidChangeOnlineUsersList = @"OnlineUsersListChanged";

static NSString *const kChatDialogsDidLoadedNotification = @"ChatDialogsLoaded";

static NSString *const kChatRoomListUpdateNotification	= @"kChatRoomListUpdateNotification";
static NSString *const kInviteFriendsDataSourceShouldRefreshNotification 	 = @"kInviteFriendsDataSourceShouldRefreshNotification";


//****************** Calls Notifications  ***********************
static NSString *const kIncomingCallNotification = @"Incoming Call";
static NSString *const kCallWasStoppedNotification = @"Call was stopped";
static NSString *const kCallWasRejectedNotification = @"Call Was Rejected";
static NSString *const kCallUserDidNotAnswerNotification = @"User didn't answer";
static NSString *const kCallDidAcceptByUserNotification = @"User accepted call";
static NSString *const kCallDidStartedByUserNotification = @"Call was started";
static NSString *const kChatViewCellIdentifier          = @"ChatViewCell";
static NSString *const kCreateChatCellIdentifier        = @"CreateChatCell";
static NSString *const kFriendsListCellIdentifier       = @"FriendsListCell";
static NSString *const kContactListCellIdentifier       = @"contactsCell";
static NSString *const kFacebookCellIdentifier          = @"facebookCell";
static NSString *const kInviteFriendCellIdentifier      = @"InviteFriendCell";



//******************** USER DEFAULTS KEYS *****************
static NSString *const kEmail       		= @"email";
static NSString *const kPassword    		= @"password";
static NSString *const kRememberMe  		= @"remember_me";
static NSString *const kFBSessionRemembered = @"facebook_session_remembered";
static NSString *const kUserStatusText   	= @"userStatusText";

static NSString *const kChatLocalHistory	= @"chatLocalHistory";
static NSString *const kChatOpponentHistory	= @"opponentHistory";
static NSString *const kChatOpponentName	= @"chatOpponentName";
static NSString *const kChatOpponentIDString	= @"chatOpponentIDString";
static NSString *const kSettingsPushNotificationsState	= @"kSettingsPushNotificationsState";

static NSString *const kId          = @"id";
static NSString *const kData        = @"data";
static NSString *const kClassName   = @"Friend";
static NSString *const kFacebook    = @"facebook";

static NSString *const kFriendId               = @"FriendID";
static NSString *const kUserDataInfoDictionary = @"QBUserObject";

static NSString *const kEmptyString                     = @"";

static NSString *const kTableHeaderFriendsString        = @"Friends";
static NSString *const kTableHeaderAllUsersString       = @"All Users";

static NSString *const kFacebookFriendStatus            = @"Facebook friend";
static NSString *const kAddressBookUserStatus           = @"Contact List";

static NSString *const kMessageString                   = @"Input email please.";
static NSString *const kMoreResultString                = @"For more results:";
static NSString *const kSearchingFriendsString          = @"You have no friends yet. Try to search for new friends";
static NSString *const kSearchFriendPlaceholdeString    = @"Search friend";
static NSString *const kNoChatString                    = @"No Chat yet";
static NSString *const kStatusOnlineString              = @"Online";
static NSString *const kStatusOfflineString             = @"Offline";

static NSString *const kMailSubjectString               = @"Q-municate";
static NSString *const kMailBodyString                  = @"<a href='http://quickblox.com/'>Join us in Q-municate!</a>";
static NSString *const kButtonTitleDoneString           = @"Done";

static NSString *const kErrorKeyFromDictionaryString    	= @"error";

static NSString *const kAlertTitleErrorString               = @"Error";
static NSString *const kAlertTitleSuccessString             = @"Success";
static NSString *const kAlertTitleInProgressString          = @"In Progress";
static NSString *const kAlertTitleEnterPasswordString       = @"Enter password:";
static NSString *const kAlertTitleAreYouSureString          = @"Are you sure?";
static NSString *const kAlertTitlePasswordIsShortString     = @"Password is too short";
static NSString *const kAlertTitleEnterNewPasswordString    = @"Enter new Password";
static NSString *const kAlertTitleConfirmNewPasswordString      = @"Confirm Password";
static NSString *const kAlertTitleChangingStatusString      = @"Changing status:";

static NSString *const kAlertBodyWrongPasswordString            = @"Wrong password";
static NSString *const kAlertBodyPasswDoesNotMatchString        = @"Passwords don't match";
static NSString *const kAlertBodyPasswordIsShortString          = @"Password is too short";
static NSString *const kAlertBodyPasswordChangedString          = @"Password changed";
static NSString *const kAlertBodyFillInAllFieldsString          = @"Fill in all the fields";
static NSString *const kAlertBodyMessageWasSentToMailString     = @"Message was sent to your email. Check it";
static NSString *const kAlertBodyRecordPostedString             = @"Record was posted to wall.";
static NSString *const kAlertBodyRecordSentViaMailString        = @"Record was sent via email.";
static NSString *const kAlertBodyNoContactsWithEmailsString     = @"No contacts with emails";
static NSString *const kAlertBodySetUpYourEmailClientString     = @"Please, set up your email client";
static NSString *const kAlertButtonTitleOkString        = @"OK";
static NSString *const kAlertButtonTitleHackItString    = @"Hack it!";
static NSString *const kAlertButtonTitleCancelString    = @"Cancel";
static NSString *const kAlertButtonTitleLogOutString    = @"Log Out";

static NSString *const kButtonTitleCreatePrivateChatString 	= @"Create Private Chat";
static NSString *const kButtonTitleCreateGroupChatString 	= @"Create Group Chat";

static NSString *const kSettingsProfileDefaultStatusString	= @"Add Status";
static NSString *const kSettingsProfileMessageWarningString	= @"This field could not be empty!";
static NSString *const kSettingsProfileTextViewMessageWarningString	= @"This field could not be more then 43 characters!";

//******************** CoreData *****************
static NSString *const kCDMessageDatetimePath = @"datetime";

extern QMLogLevel kLoggingLevel;

#endif
