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


//****************** Blocks *********************************
typedef void (^QBResultBlock)(Result *result);
typedef void (^QBSessionCreationBlock)(BOOL success, NSError *error);
typedef void (^QBAuthResultBlock)(QBUUser *user, BOOL success, NSError *error);
typedef void (^QBChatResultBlock)(BOOL success);
typedef void (^QBContactListBlock)(id object);
typedef void (^QBContentBlock)(QBCBlob *blob);
typedef void (^QBDataBlock)(id data);

typedef void(^FBResultBlock)(NSArray *users, BOOL success, NSError *error);
typedef void(^FBCompletionBlock)(BOOL success, NSError *error);

typedef void(^AddressBookResult)(NSArray *contacts, BOOL success, NSError *error);


//************** Segue Identifiers *************************
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

//****************** Cell Identifiers  ********************
static NSString *const kSettingsVCCellIdentifier      = @"SettingsCellIdentifier";

//**************** Setting Cell Titles ********************
static NSString *const kSettingsCellTitleProfile            = @"Profile";
static NSString *const kSettingsCellTitlePushNotifications  = @"Push Notifications";
static NSString *const kSettingsCellTitleChangePassword     = @"Change Password";
static NSString *const kSettingsCellTitleVersion            = @"Version: 1.0.2a";

//****************** Notifications  ***********************
static NSString *const kFriendsLoadedNotification     = @"Friends Loaded";
static NSString *const kAllUsersLoadedNotification    = @"All users loaded";
static NSString *const kLoggedInNotification          = @"LoggedInNotification";


//****************** Calls Notifications  ***********************
static NSString *const kIncomingCallNotification = @"Incomming Call";
static NSString *const kCallWasStoppedNotification = @"Call was stopped";
static NSString *const kCallWasRejectedNotification = @"Call Was Rejected";
static NSString *const kCallUserDidNotAnswerNotification = @"User didn't answer";
static NSString *const kCallDidAcceptByUserNotification = @"User accepted call";
static NSString *const kCallDidStartedByUserNotification = @"Call was started";


//******************** USER DEFAULTS KEYS *****************
static NSString *const kEmail       		= @"email";
static NSString *const kPassword    		= @"password";
static NSString *const kRememberMe  		= @"remember_me";
static NSString *const kDidLogout   		= @"didLogout";
static NSString *const kUserStatusText   	= @"userStatusText";

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

static NSString *const kChatViewCellIdentifier          = @"ChatViewCell";
static NSString *const kCreateChatCellIdentifier        = @"CreateChatCell";
static NSString *const kFriendsListCellIdentifier       = @"FriendsListCell";
static NSString *const kContactListCellIdentifier       = @"contactsCell";
static NSString *const kFacebookCellIdentifier          = @"facebookCell";
static NSString *const kInviteFriendCellIdentifier      = @"InviteFriendCell";

static NSString *const kMessageString                   = @"Input email please.";
static NSString *const kMoreResultString                = @"For more results:";
static NSString *const kSearchingFriendsString          = @"You have no friends yet. Try to search for new friends";
static NSString *const kSearchFriendPlaceholdeString    = @"Search friend";
static NSString *const kNoChatString                    = @"No Chat yet";
static NSString *const kStatusOnlineString              = @"Online";
static NSString *const kStatusOfflineString             = @"Offline";

static NSString *const kMailSubjectString               = @"Q-municate";
static NSString *const kMailBodyString                  = @"Join us in Q-municate!";
static NSString *const kButtonTitleDoneString           = @"Done";

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
static NSString *const kAlertButtonTitleOkString        = @"OK";
static NSString *const kAlertButtonTitleHackItString    = @"Hack it!";
static NSString *const kAlertButtonTitleCancelString    = @"Cancel";
static NSString *const kAlertButtonTitleLogOutString    = @"Log Out";

static NSString *const kButtonTitleCreatePrivateChatString 	= @"Create Private Chat";
static NSString *const kButtonTitleCreateGroupChatString 	= @"Create Group Chat";

static NSString *const kSettingsProfileDefaultStatusString	= @"Add Status";


extern QMLogLevel kLoggingLevel;

#endif
