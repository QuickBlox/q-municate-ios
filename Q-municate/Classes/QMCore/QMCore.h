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

@property (strong, nonatomic) NSString *activeDialogID;

/**
 *  QMCore shared instance.
 *
 *  @return QMCore singleton
 */
+ (instancetype)instance;

- (BFTask *)disconnectFromChat;
- (BFTask *)disconnectFromChatIfNeeded;

- (NSArray *)friends;
- (NSArray *)friendsSortedByFullName;
- (NSArray *)idsOfContactsOnly;
- (BOOL)isFriendWithUserID:(NSUInteger)userID;
- (NSArray *)idsOfUsers:(NSArray *)users;
- (BOOL)userIDIsInPendingList:(NSUInteger)userID;

- (BFTask *)logout;

- (BFTask *)leaveChatDialog:(QBChatDialog *)chatDialog;

#pragma mark - Contacts management

- (BFTask *)addUserToContactList:(QBUUser *)user;
- (BFTask *)confirmAddContactRequest:(QBUUser *)user;
- (BFTask *)rejectAddContactRequest:(QBUUser *)user;
- (BOOL)isUserOnline:(NSUInteger)userID;
- (NSString *)fullNameForUserID:(NSUInteger)userID;

@end
