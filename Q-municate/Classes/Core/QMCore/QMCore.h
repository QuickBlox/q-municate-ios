//
//  QMCore.h
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 1/8/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMServicesManager.h"

#import "QMProfile.h"

#import "QMContactManager.h"
#import "QMChatManager.h"
#import "QMPushNotificationManager.h"
#import "QMOpenGraphService.h"
#import "QMCallManager.h"

@class Reachability;

NS_ASSUME_NONNULL_BEGIN

/**
 *  This class represents basic control on QMServices.
 */
@interface QMCore : QMServicesManager
<QMContactListServiceCacheDataSource, QMContactListServiceDelegate,
QMOpenGraphCacheDataSource, QMOpenGraphServiceDelegate>

/**
 *  Contact list service.
 */
@property (strong, nonatomic, readonly) QMContactListService *contactListService;

/**
 Open Graph serice
 */
@property (strong, nonatomic, nonnull) QMOpenGraphService *openGraphService;

/**
 *  Contact manager.
 */
@property (strong, nonatomic, readonly) QMContactManager *contactManager;

/**
 *  Chat manager.
 */
@property (strong, nonatomic, readonly) QMChatManager *chatManager;

/**
 *  Push notification manager.
 */
@property (strong, nonatomic, readonly) QMPushNotificationManager *pushNotificationManager;

/**
 *  Call notification manager.
 */
@property (strong, nonatomic, readonly) QMCallManager *callManager;

/**
 *  Reachability manager.
 */
@property (strong, nonatomic, readonly) Reachability *internetConnection;

/**
 *  Current profile.
 *
 *  @see QMProfile class.
 */
@property (strong, nonatomic, readonly) QMProfile *currentProfile;

/**
 Active dialog ID
 */
@property (copy, nonatomic, nullable) NSString *activeDialogID;

/**
 *  QMCore shared instance.
 *
 *  @return QMCore singleton
 */

@property (class, readonly) QMCore *instance;

- (BOOL)isInternetConnected;

- (BFTask *)login;
- (BFTask *)logout;

@end

NS_ASSUME_NONNULL_END
