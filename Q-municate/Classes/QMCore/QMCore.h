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
@interface QMCore : QMServicesManager

<
QMContactListServiceCacheDataSource,
QMContactListServiceDelegate
>

/**
 *  Contact list service.
 */
@property (strong, nonatomic, readonly) QMContactListService* contactListService;

/**
 *  Reachability manager.
 */
@property (strong, nonatomic, readonly) Reachability *internetConnection;

@property (strong, nonatomic, readonly) QMProfile *currentProfile;

@property (strong, nonatomic) NSDate *lastActivityDate;

/**
 *  QMCore shared instance.
 *
 *  @return QMCore singleton
 */
+ (instancetype)instance;

- (NSArray *)friends;
- (NSArray *)friendsSortedByFullName;
- (NSArray *)idsOfContactsOnly;
- (BOOL)isFriendWithUser:(QBUUser *)user;
- (NSArray *)idsOfUsers:(NSArray *)users;

- (BFTask *)logout;

- (BFTask *)leaveChatDialog:(QBChatDialog *)chatDialog;

#pragma mark - Contacts management

- (BFTask *)addUserToContactList:(QBUUser *)user;
- (BFTask *)confirmAddContactRequest:(QBUUser *)user;

@end
