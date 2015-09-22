//
//  QMDefinitions.h
//  Q-municate
//
//  Created by Igor Alefirenko on 14/02/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#ifndef Q_municate_Definitions_h
#define Q_municate_Definitions_h

#define QM_TEST 0

#define QM_AUDIO_VIDEO_ENABLED 1

#define DELETING_DIALOGS_ENABLED 0

#define IS_HEIGHT_GTE_568 [[UIScreen mainScreen ] bounds].size.height >= 568.0f
#define $(...)  [NSSet setWithObjects:__VA_ARGS__, nil]

#define CHECK_OVERRIDE()\
@throw\
[NSException exceptionWithName:NSInternalInconsistencyException \
reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]\
userInfo:nil]

/*QMContentService*/
typedef void(^QMContentProgressBlock)(float progress);
typedef void(^QMCFileUploadResponseBlock)(QBResponse *response, QBCBlob *blob);
typedef void(^QMCFileDownloadResponseBlock)(QBResponse *response, NSData *fileData);
typedef void (^QBUUserResponseBlock)(QBResponse *response, QBUUser *user);
//typedef void (^QBAAuthResultBlock)(QBAAuthResult *result);
//typedef void (^QBUUserLogInResultBlock)(QBUUserLogInResult *result);
//typedef void (^QBAAuthSessionCreationResultBlock)(QBAAuthSessionCreationResult *result);
//typedef void (^QBUUserPagedResultBlock)(QBUUserPagedResult *pagedResult);
typedef void (^QBUUserPagedResponseBlock)(QBResponse *response, QBGeneralResponsePage *page, NSArray *users);
typedef void (^QBDialogsPagedResponseBlock)(QBResponse *response, NSArray *dialogObjects, NSSet *dialogsUsersIDs, QBResponsePage *page);
typedef void (^QBChatDialogResponseBlock)(QBResponse *response, QBChatDialog *createdDialog);
typedef void (^QBChatHistoryMessageResponseBlock)(QBResponse *response, NSArray *messages, QBResponsePage *responsePage);

typedef void (^QBResponseBlock)(QBResponse *response);
//typedef void (^QBSessionCreationBlock)(BOOL success, NSString *error);
typedef void (^QBChatResultBlock)(BOOL success);
//typedef void (^QBChatRoomResultBlock)(QBChatRoom *chatRoom, NSError *error);
//typedef void (^QBChatDialogHistoryBlock)(NSMutableArray *chatDialogHistoryArray, NSError *error);

//************** Segue Identifiers *************************
static NSString *const kTabBarSegueIdnetifier         = @"TabBarSegue";
static NSString *const kSplashSegueIdentifier         = @"SplashSegue";
static NSString *const kWelcomeScreenSegueIdentifier  = @"WelcomeScreenSegue";
static NSString *const kSignUpSegueIdentifier         = @"SignUpSegue";
static NSString *const kLogInSegueSegueIdentifier     = @"LogInSegue";
static NSString *const kDetailsSegueIdentifier        = @"DetailsSegue";
static NSString *const kVideoCallSegueIdentifier      = @"VideoCallSegue";
static NSString *const kAudioCallSegueIdentifier      = @"AudioCallSegue";
static NSString *const kGoToDuringAudioCallSegueIdentifier = @"goToDuringAudioCallSegueIdentifier";
static NSString *const kGoToDuringVideoCallSegueIdentifier = @"goToDuringVideoCallSegueIdentifier";
static NSString *const kChatViewSegueIdentifier       = @"ChatViewSegue";
static NSString *const kIncomingCallIdentifier        = @"IncomingCallIdentifier";
static NSString *const kProfileSegueIdentifier        = @"ProfileSegue";
static NSString *const kCreateNewChatSegueIdentifier  = @"CreateNewChatSegue";
static NSString *const kContentPreviewSegueIdentifier = @"ContentPreviewIdentifier";
static NSString *const kGroupDetailsSegueIdentifier   = @"GroupDetailsSegue";
static NSString *const kQMAddMembersToGroupControllerSegue = @"QMAddMembersToGroupControllerSegue";

static NSString *const kSettingsCellBundleVersion = @"CFBundleVersion";

//******************** USER DEFAULTS KEYS *****************

static NSString *const kMailSubjectString               = @"Q-municate";
static NSString *const kMailBodyString                  = @"<a href='http://quickblox.com/'>Join us in Q-municate!</a>";

#endif
