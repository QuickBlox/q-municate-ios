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

#define STAGE_SERVER_IS_ACTIVE 0

#define DELETING_DIALOGS_ENABLED 0

#define IS_HEIGHT_GTE_568 [[UIScreen mainScreen ] bounds].size.height >= 568.0f

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
static NSString *const kQMAddMembersToGroupControllerSegue = @"QMAddMembersToGroupControllerSegue";

static NSString *const kSettingsCellBundleVersion = @"CFBundleVersion";

//******************** USER DEFAULTS KEYS *****************

static NSString *const kMailSubjectString               = @"Q-municate";
static NSString *const kMailBodyString                  = @"<a href='http://quickblox.com/'>Join us in Q-municate!</a>";

#endif
