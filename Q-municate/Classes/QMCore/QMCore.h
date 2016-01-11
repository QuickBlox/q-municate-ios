//
//  QMCore.h
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 1/8/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMServicesManager.h"

@class Reachability;
@class QMProfile;

/**
 *  This class represents basic control on QMServices.
 */
@interface QMCore : QMServicesManager <QMContactListServiceCacheDataSource>

/**
 *  Contact list service.
 */
@property (strong, nonatomic, readonly) QMContactListService* contactListService;

/**
 *  Reachability manager.
 */
@property (strong, nonatomic, readonly) Reachability *internetConnection;

@property (strong, nonatomic, readonly) QMProfile *currentProfile;

/**
 *  QMCore shared instance.
 *
 *  @return QMCore singleton
 */
+ (instancetype)instance;

@end
