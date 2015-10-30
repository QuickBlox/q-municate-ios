//
//  QMUsersService.h
//  QMUsersService
//
//  Created by Andrey Moskvin on 10/23/15.
//  Copyright © 2015 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QMBaseService.h"
#import "QMUsersMemoryStorage.h"

@class QMCancellationToken;

@protocol QMUsersServiceDelegate;
@protocol QMUsersServiceCacheDataSource;

@interface QMUsersService : QMBaseService

/**
 *  Memory storage for users items.
 */
@property (strong, nonatomic, readonly) QMUsersMemoryStorage *usersMemoryStorage;

/**
 *  Init with service data delegate and contact list cache protocol.
 *
 *  @param serviceDataDelegate instance confirmed id<QMServiceDataDelegate> protocol
 *  @param cacheDataSource       instance confirmed id<QMUsersServiceCacheDataSource> protocol
 *
 *  @return QMContactListService instance
 */
- (instancetype)initWithServiceManager:(id<QMServiceManagerProtocol>)serviceManager
                       cacheDataSource:(id<QMUsersServiceCacheDataSource>)cacheDataSource;

/**
 *  Add instance that confirms contact list service multicaste protocol
 *
 *  @param delegate instance that confirms id<QMContactListServiceDelegate> protocol
 */
- (void)addDelegate:(id <QMUsersServiceDelegate>)delegate;

/**
 *  Remove instance that confirms contact list service multicaste protocol
 *
 *  @param delegate instance that confirms id<QMContactListServiceDelegate> protocol
 */
- (void)removeDelegate:(id <QMUsersServiceDelegate>)delegate;

#pragma mark - Intelligent fetch

/**
 *  Retrieving user if needed.
 *
 *  @param userID       id of user to retrieve
 *  @param completion   completion block with boolean value YES if retrieve was needed
 */
- (BFTask<QBUUser *> *)retrieveUserWithID:(NSUInteger)userID;

/**
 *  Retrieving users if needed.
 *
 *  @param userIDs      array of users ids to retrieve
 *  @param completion   completion block with boolean value YES if retrieve was needed
 */
- (BFTask<NSArray<QBUUser *> *> *)retrieveUsersWithIDs:(NSArray<NSNumber *> *)usersIDs;

/**
 *  Retrieve users with emails
 *
 *  @param emails     emails to search users with
 *  @param completion Block with response, page and users instances if request succeded
 */
- (BFTask<NSArray<QBUUser *> *> *)retrieveUsersWithEmails:(NSArray<NSString *> *)emails;

/**
 *  Retrieve users with facebook ids (with extended set of pagination parameters)
 *
 *  @param facebookIDs facebook ids to search
 *  @param completion  Block with response, page and users instances if request succeded
 */
- (BFTask<NSArray<QBUUser *> *> *)retrieveUsersWithFacebookIDs:(NSArray<NSString *> *)facebookIDs;

- (BFTask<NSArray<QBUUser *> *> *)retrieveUsersWithLogins:(NSArray<NSString *> *)logins;


#pragma mark - Search

/**
 *  Retrieve users with full name
 *
 *  @param  searchText string with full name
 *  @param  pagedRequest extended set of pagination parameters
 *
 *  @return QBRequest cancelable instance
 */
- (BFTask<NSArray<QBUUser *> *> *)searchUsersWithFullName:(NSString *)searchText;

@end

#pragma mark - Protocols

/**
 *  Data source for QMContactList Service
 */

@protocol QMUsersServiceCacheDataSource <NSObject>
@required

/**
 * Is called when chat service will start. Need to use for inserting initial data QMUsersMemoryStorage
 *
 *  @param block Block for provide QBUUsers collection
 */
- (void)cachedUsers:(void(^)(NSArray* collection))block;

@end

@protocol QMUsersServiceDelegate <NSObject>

@optional

- (void)usersService:(QMUsersService *)usersService didAddUsers:(NSArray<QBUUser *> *)user;

@end
