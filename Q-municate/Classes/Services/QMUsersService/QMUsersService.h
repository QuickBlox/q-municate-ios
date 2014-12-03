//
//  QMUsersService.h
//  Q-municate
//
//  Created by Ivanov A.V on 14/02/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QMBaseService.h"

@interface QMUsersService : QMBaseService

@property (strong, nonatomic) NSMutableArray *contactList;
#warning HARDFIX: property friendsOnly
@property (strong, nonatomic) NSMutableArray *friendsOnly;
@property (strong, nonatomic) NSMutableSet *confirmRequestUsersIDs;

- (void)addUsers:(NSArray *)users;
- (void)addUser:(QBUUser *)user;
- (void)deleteUser:(QBUUser *)user;
- (BOOL)deleteContactRequestUserID:(NSUInteger)contactUserID;

- (NSArray *)idsOfUsers:(NSArray *)users;
- (NSArray *)idsOfContactsOnly;
- (QBUUser *)userWithID:(NSUInteger)userID;
- (NSArray *)checkExistIds:(NSArray *)ids;
- (NSArray *)usersIDsToFetch:(NSArray *)IDs;
- (NSArray *)idsFromContactListItems;
- (BOOL)isFriendWithID:(NSUInteger)ID;

- (void)retriveIfNeededUserWithID:(NSUInteger)userID completion:(void(^)(BOOL retrieveWasNeeded))completionBlock;
- (void)retriveIfNeededUsersWithIDs:(NSArray *)usersIDs completion:(void(^)(BOOL retrieveWasNeeded))completionBlock;

- (void)retrieveUsersWithIDs:(NSArray *)idsToFetch completion:(void(^)(BOOL updated))completion;
/**
 Retrieve users with facebook ids (max 10 users, for more - use equivalent method with 'pagedRequest' argument)
 
 Type of Result - QBUUserPagedResult
 
 @param facebookIDs Facebook IDs of users which you want to retrieve
 @param completion finish of the request, result will be an instance of QBUUserPagedResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
- (NSObject<Cancelable> *)retrieveUsersWithFacebookIDs:(NSArray *)facebookIDs completion:(QBUUserPagedResultBlock)completion;

/**
Retrieve users with ids (with extended set of pagination parameters)

Type of Result - QBUUserPagedResult

@param ids IDs of users which you want to retrieve
@param pagedRequest paged request
@param completion finish of the request, result will be an instance of QBUUserPagedResult class.
@return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
*/
- (NSObject<Cancelable> *)retrieveUsersWithIDs:(NSArray *)ids pagedRequest:(PagedRequest *)pagedRequest completion:(QBUUserPagedResultBlock)completion;

/**
 Retrieve all Users for current account (with extended set of pagination parameters)
 
 Type of Result - QBUUserPagedResult
 
 @param pagedRequest paged request
 @param completion finish of the request, result will be an instance of QBUUserPagedResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
- (NSObject<Cancelable> *)retrieveUsersWithPagedRequest:(PagedRequest *)pagedRequest completion:(QBUUserPagedResultBlock)completion;

/**
 Retrieve Users by full name for current account (with extended set of pagination parameters)
 
 Type of Result - QBUUserPagedResult
 
 @param userFullName Full name of users to be retrieved.
 @param pagedRequest paged request
 @param completion  finish of the request, result will be an instance of QBUUserPagedResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
- (NSObject<Cancelable> *)retrieveUsersWithFullName:(NSString *)fullName pagedRequest:(PagedRequest *)pagedRequest completion:(QBUUserPagedResultBlock)completion;

/**
 Retrieve Users by full name for current account (with extended set of pagination parameters)
 
 Type of Result - QBUUserPagedResult
 
 @param userFullName Full name of users to be retrieved.
 @param pagedRequest paged request
 @param completion  finish of the request, result will be an instance of QBUUserPagedResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
- (NSObject<Cancelable> *)retrieveUserWithID:(NSUInteger)userID completion:(QBUUserResultBlock)completion;
/**
 Retrieve users with email (max 10 users, for more - use equivalent method with 'pagedRequest' argument)
 
 Type of Result - QBUUserPagedResult
 
 @param email Emails of users which you want to retrieve
 @param completion finish of the request, result will be an instance of QBUUserPagedResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
- (NSObject<Cancelable> *)retrieveUsersWithEmails:(NSArray *)emails completion:(QBUUserPagedResultBlock)completion;
/**
 Reset user's password. User with this email will retrieve email instruction for reset password.
 Type of Result - Result
 @param email User's email
 */

- (NSObject<Cancelable> *)resetUserPasswordWithEmail:(NSString *)email completion:(QBResultBlock)completion;
/**
 Update User
 Type of Result - QBUUserResult
 @param user An instance of QBUUser, describing the user to be edited.
 */
- (NSObject<Cancelable> *)updateUser:(QBUUser *)user withCompletion:(QBUUserResultBlock)completion;

@end
