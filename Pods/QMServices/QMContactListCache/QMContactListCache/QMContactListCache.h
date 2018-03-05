//
//  QMContactListCache.h
//  QMServices
//
//  Created by Andrey Ivanov on 06.11.14.
//  Copyright (c) 2015 Quickblox Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QMDBStorage.h"

NS_ASSUME_NONNULL_BEGIN

@interface QMContactListCache : QMDBStorage

//MARK: - Singleton

/**
 *  Chat cache singleton
 *
 *  @return QMContactListCache instance
 */
+ (nullable QMContactListCache *)instance;

//MARK: - Configure store

/**
 *  Setup QMContactListCache stake wit store name
 *
 *  @param storeName Store name
 */
+ (void)setupDBWithStoreNamed:(NSString *)storeName;
/**
 *  Clean clean chat cache with store name
 *
 *  @param name Store name
 */
+ (void)cleanDBWithStoreName:(NSString *)name;

//MARK: -
//MARK: Dialogs
//MARK: -
//MARK: Insert / Update / Delete contact items

/**
 *  Insert/Update QBContactListItem in cache
 *
 *  @param contactListItems QBContactListItem instance
 *  @param completion       Completion block is called after update or insert operation is completed
 */
- (void)insertOrUpdateContactListItem:(QBContactListItem *)contactListItems
                           completion:(nullable dispatch_block_t)completion;
/**
 *  Insert/Update QBContactListItem's in cache
 *
 *  @param contactListItems Array of QBContactListItem instances
 *  @param completion       Completion block is called after update or insert operation is completed
 */
- (void)insertOrUpdateContactListWithItems:(NSArray<QBContactListItem *> *)contactListItems
                                completion:(nullable dispatch_block_t)completion;

/**
 *  Insert/Update QBContactListItem's in cache
 *
 *  @param contactList QBContactList instance
 *  @param completion  Completion block is called after update or insert operation is completed
 */
- (void)insertOrUpdateContactListItemsWithContactList:(QBContactList *)contactList
                                           completion:(nullable dispatch_block_t)completion;
/**
 *  Delete ContactListItem from cache
 *
 *  @param contactListItem  QBContactListItem instance
 *  @param completion       Completion block is called after delete operation is completed
 */
- (void)deleteContactListItem:(QBContactListItem *)contactListItem
                   completion:(nullable dispatch_block_t)completion;

/**
 *  Delete all contact list items
 *
 *  @param completion Completion block is called after delete contact list items operation is completed
 */
- (void)deleteContactList:(nullable dispatch_block_t)completion;

- (void)truncateAll;

//MARK: Fetch ContactList operations

/**
 *  Fetch all contact list items
 *
 *  @param completion Completion block that is called after the fetch has completed. Returns an array of QBContactListItem instances
 */
- (void)contactListItems:(nullable void(^)(NSArray<QBContactListItem *> *contactListItems))completion;


/**
 *  Fetch all contact list items (Fetch in Main Queue context)
 *
 *  @return Returns an array of QBContactListItem instances
 */
- (NSArray<QBContactListItem *> *)allContactListItems;

/**
 *  Fetch contact list item wiht user ID
 *
 *  @param userID     userID which you would like to Fetch from cache
 *  @param completion Completion block that is called after the fetch has completed. Returns an instance of QBContactListItem
 */
- (void)contactListItemWithUserID:(NSUInteger)userID
                       completion:(nullable void(^)(QBContactListItem *contactListItems))completion;


@end

NS_ASSUME_NONNULL_END
