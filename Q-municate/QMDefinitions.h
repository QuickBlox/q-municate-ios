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
typedef void(^QBUUserPagedResponseBlock)(QBResponse *response, QBGeneralResponsePage *page, NSArray *users);

/*ChatDialogs constants*/
static const NSUInteger kQMDialogsPageLimit = 10;

//******************** CoreData ********************

static NSString *const kChatCacheNameKey                    = @"q-municate";
static NSString *const kContactListCacheNameKey             = @"q-municate-contacts";
static NSString *const kUsersCacheNameKey                   = @"qb-users-cache";

//******************** Segue Identifiers ********************
static NSString *const kVideoCallSegueIdentifier            = @"VideoCallSegue";
static NSString *const kAudioCallSegueIdentifier            = @"AudioCallSegue";
static NSString *const kGoToDuringAudioCallSegueIdentifier  = @"goToDuringAudioCallSegueIdentifier";
static NSString *const kGoToDuringVideoCallSegueIdentifier  = @"goToDuringVideoCallSegueIdentifier";
static NSString *const kChatViewSegueIdentifier             = @"ChatViewSegue";
static NSString *const kIncomingCallIdentifier              = @"IncomingCallIdentifier";
static NSString *const kSettingsCellBundleVersion           = @"CFBundleVersion";

//******************** USER DEFAULTS KEYS ********************
static NSString *const kMailSubjectString                   = @"Q-municate";
static NSString *const kMailBodyString                      = @"<a href='http://quickblox.com/'>Join us in Q-municate!</a>";

//******************** NOTIFICATIONS ********************
static NSString *const kPushNotificationDialogIDKey         = @"dialog_id";
static NSString *const kDialogsUpdateNotificationMessage    = @"Notification message";
static NSString *const kUsersLoadingFinishedNotifications   = @"kUsersLoadingFinishedNotifications";

#endif
