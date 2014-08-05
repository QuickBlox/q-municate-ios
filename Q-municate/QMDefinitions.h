//
//  QMDefinitions.h
//  Q-municate
//
//  Created by Igor Alefirenko on 14/02/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#ifndef Q_municate_Definitions_h
#define Q_municate_Definitions_h

#define QM_TEST 1
#define QM_AUDIO_VIDEO_ENABLED 0

#define IS_HEIGHT_GTE_568 [[UIScreen mainScreen ] bounds].size.height == 568.0f
#define $(...)  [NSSet setWithObjects:__VA_ARGS__, nil]

#define CHECK_OVERRIDE()\
@throw\
[NSException exceptionWithName:NSInternalInconsistencyException \
reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]\
userInfo:nil]

/*QMContentService*/
typedef void(^QMContentProgressBlock)(float progress);
typedef void(^QMCFileUploadTaskResultBlockBlock)(QBCFileUploadTaskResult *result);
typedef void(^QMCFileDownloadTaskResultBlockBlock)(QBCFileDownloadTaskResult *result);
typedef void (^QBUUserResultBlock)(QBUUserResult *result);
typedef void (^QBAAuthResultBlock)(QBAAuthResult *result);
typedef void (^QBUUserLogInResultBlock)(QBUUserLogInResult *result);
typedef void (^QBAAuthSessionCreationResultBlock)(QBAAuthSessionCreationResult *result);
typedef void (^QBUUserPagedResultBlock)(QBUUserPagedResult *pagedResult);
typedef void (^QBMRegisterSubscriptionTaskResultBlock)(QBMRegisterSubscriptionTaskResult *result);
typedef void (^QBMUnregisterSubscriptionTaskResultBlock)(QBMUnregisterSubscriptionTaskResult *result);
typedef void (^QBDialogsPagedResultBlock)(QBDialogsPagedResult *result);
typedef void (^QBChatDialogResultBlock)(QBChatDialogResult *result);
typedef void (^QBChatHistoryMessageResultBlock)(QBChatHistoryMessageResult *result);

typedef void (^QBResultBlock)(Result *result);
typedef void (^QBSessionCreationBlock)(BOOL success, NSString *error);
typedef void (^QBChatResultBlock)(BOOL success);
typedef void (^QBChatRoomResultBlock)(QBChatRoom *chatRoom, NSError *error);
typedef void (^QBChatDialogHistoryBlock)(NSMutableArray *chatDialogHistoryArray, NSError *error);

//************** Segue Identifiers *************************
static NSString *const kTabBarSegueIdnetifier         = @"TabBarSegue";
static NSString *const kSplashSegueIdentifier         = @"SplashSegue";
static NSString *const kWelcomeScreenSegueIdentifier  = @"WelcomeScreenSegue";
static NSString *const kSignUpSegueIdentifier         = @"SignUpSegue";
static NSString *const kLogInSegueSegueIdentifier     = @"LogInSegue";
static NSString *const kDetailsSegueIdentifier        = @"DetailsSegue";
static NSString *const kVideoCallSegueIdentifier      = @"VideoCallSegue";
static NSString *const kAudioCallSegueIdentifier      = @"AudioCallSegue";
static NSString *const kStartAudioCallSegueIdentifier = @"StartAudioCallSegue";
static NSString *const kStartVideoCallSegueIdentifier = @"StartVideoCallSegue";
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

//static NSString *const kUserDoesntAnswerStatus      = @"User doesn't answer";
//
//static NSString *const kCallWasStoppedByUserStatus  = @"Call was stopped";
static NSString *const kCallConnectingStatus        = @"Connecting...";


//******************** USER DEFAULTS KEYS *****************

static NSString *const kFacebook    = @"facebook";

//static NSString *const kFriendId               = @"FriendID";
//static NSString *const kUserDataInfoDictionary = @"QBUserObject";

static NSString *const kEmptyString                     = @"";

//static NSString *const kMoreResultString                = @"For more results:";
static NSString *const kSearchingFriendsString          = @"You have no friends yet. Try to search for new friends";
static NSString *const kNoChatString                    = @"No Chat yet";

static NSString *const kMailSubjectString               = @"Q-municate";
static NSString *const kMailBodyString                  = @"<a href='http://quickblox.com/'>Join us in Q-municate!</a>";
static NSString *const kButtonTitleDoneString           = @"Done";

static NSString *const kSettingsProfileDefaultStatusString	= @"Add Status";
static NSString *const kSettingsProfileMessageWarningString	= @"This field could not be empty!";
static NSString *const kSettingsProfileTextViewMessageWarningString	= @"This field could not be more then 43 characters!";

#endif
