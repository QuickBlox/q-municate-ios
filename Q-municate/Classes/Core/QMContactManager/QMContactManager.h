//
//  QMContactsManager.h
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 3/25/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMBaseService.h"

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

/**
 *  Array of user IDs by excluding current user ID.
 *
 *  @param occupantIDs array of user ids
 *
 *  @return array of user ids without current user
 */
- (NSArray <NSNumber *> *)occupantsWithoutCurrentUser:(NSArray <NSNumber *> *)occupantIDs;

/**
 *  Online status string for user.
 *
 *  @param user QBUUser instance.
 *
 *  @return Online status string.
 */
- (NSString *)onlineStatusForUser:(QBUUser *)user;

/**
 Subscription state.

 @param userID opponent user ID.
 @return Subscription state. @see `QBPresenseSubscriptionState`
 */
- (QBPresenseSubscriptionState)subscriptionStateWithUserID:(NSUInteger)userID;

/**
 *  Determines whether user with ID is friend.
 *
 *  @param userID opponent user ID
 *
 *  @return is user with ID friend
 */
- (BOOL)isFriendWithUserID:(NSUInteger)userID;

/**
 *  Whether contact list item is existent for a specific user ID.
 *
 *  @param userID user ID to check contact list item for
 *
 *  @return whether contact list item existent
 */
- (BOOL)isContactListItemExistentForUserWithID:(NSUInteger)userID;

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
