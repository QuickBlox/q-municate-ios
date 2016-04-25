//
//  QMContactsManager.h
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 3/25/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class QMCore;

/**
 *  This class represents basic contacts managing and tasks.
 */
@interface QMContactManager : QMBaseService

/**
 *  Add user to contact list or confirm already existent request and send chat and push notification.
 *
 *  @param user user to add to contact list
 *
 *  @return BFTask with all performed tasks
 */
- (BFTask *)addUserToContactList:(QBUUser *)user;

/**
 *  Reject add user to contact list and send notification.
 *
 *  @param user user to reject adding
 *
 *  @return BFTask with all performed tasks
 */
- (BFTask *)rejectAddContactRequest:(QBUUser *)user;

/**
 *  Remove user from contact list and send notification.
 *
 *  @param user user to remove from contact list
 *
 *  @return BFTask with all performed tasks
 */
- (BFTask *)removeUserFromContactList:(QBUUser *)user;

/**
 *  Full name of user ID.
 *
 *  @param userID user ID to fetch full name from
 *
 *  @return full name for user
 */
- (NSString *)fullNameForUserID:(NSUInteger)userID;

/**
 *  All contacts from contact list.
 *
 *  @return all contacts that are existent in contact list
 */
- (NSArray <QBUUser *> *)allContacts;

/**
 *  All contacts from contact list sorted by full name.
 *
 *  @return all contacts that are existent in contact list sorted by fullName field
 */
- (nullable NSArray <QBUUser *> *)allContactsSortedByFullName;

/**
 *  All friends from contact list.
 *
 *  @return all friends from contact list (only with subscription state Both)
 */
- (NSArray <QBUUser *> *)friends;

/**
 *  Friends by excluding some users with ids.
 *
 *  @param userIDs user ids to exclude from.
 *
 *  @return friends without exlcuded users
 */
- (NSArray <QBUUser *> *)friendsByExcludingUsersWithIDs:(NSArray <NSNumber *> *)userIDs;

/**
 *  Ids of users from array.
 *
 *  @param users array of QBUUser instances
 *
 *  @return array of user ids
 */
- (NSArray <NSNumber *> *)idsOfUsers:(NSArray <QBUUser *> *)users;

- (NSString *)onlineStatusForUser:(QBUUser *)user;

/**
 *  Determines whether user with ID is friend.
 *
 *  @param userID opponent user ID
 *
 *  @return is user with ID friend
 */
- (BOOL)isFriendWithUserID:(NSUInteger)userID;

/**
 *  Determines whether user with ID is in pending list.
 *
 *  @param userID opponent user ID
 *
 *  @return is user with ID in pending list
 */
- (BOOL)isUserIDInPendingList:(NSUInteger)userID;

/**
 *  Determines whether awaiting for approval from user with ID.
 *
 *  @param userID opponent user ID
 *
 *  @return is awaiting for approval from user with ID
 */
- (BOOL)isAwaitingForApprovalFromUserID:(NSUInteger)userID;

/**
 *  Determines whether user with ID is online.
 *
 *  @param userID opponent user ID
 *
 *  @return is user with ID online
 */
- (BOOL)isUserOnlineWithID:(NSUInteger)userID;

@end

NS_ASSUME_NONNULL_END
