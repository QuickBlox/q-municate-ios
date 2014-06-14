//
//  QBStorage.h
//  Q-municate
//
//  Created by Igor Alefirenko on 14/02/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QMContactList : NSObject <QBActionStatusDelegate>

+ (instancetype)shared;

/** Me */
@property (strong, nonatomic) QBUUser *me;
@property (strong, nonatomic) NSMutableDictionary *facebookMe;

/** Users for invite friends */
@property (strong, nonatomic) NSArray *facebookFriendsToInvite;
@property (strong, nonatomic) NSArray *contactsToInvite;

/** Friends */
@property (strong, nonatomic) NSMutableDictionary *friendsAsDictionary;

/** Searched users & all cached users */
@property (strong, nonatomic) NSMutableDictionary *searchedUsers;
@property (strong, nonatomic) NSMutableDictionary *allUsersAsDictionary;

@property (strong, nonatomic) NSMutableDictionary *baseUserIDs;


#pragma mark -
#pragma mark ROASTER

/**
 Request for users for IDs in Roaster. Returns NSArray of QBUUser's
 */
- (void)retrieveFriendsWithContactListInfo:(QBContactList *)contactList completion:(void (^)(BOOL success, NSError *error))completion;


/** 
 Request for Facebook users in Quickblox database. Returns NSArray of QBUUser's
 */
- (void)retrieveFriendsFromFacebookWithCompletion:(QBPagedUsersBlock)block;


/** 
 Request for Facebook friends. Returns friends as FBGraphObjects (extended NSMutableDictionary)
 */
- (void)fetchFriendsFromFacebookWithCompletion:(QBPagedUsersBlock)handler;


/**
 Retrieving user for user id. Returns QBUUser
 */
- (void)retrieveUserWithID:(NSUInteger)userID completion:(void(^)(QBUUser *user, NSError *error))completion;


/**
 Retrieving users with full name. Returns NSArray of QBUUser's
 */
- (void)retrieveUsersWithFullName:(NSString *)fullName usingBlock:(QBPagedUsersBlock)block;

/**
 Retrieving users with IDs. Returns NSArray of QBUUser's
 */
- (void)retrieveUsersWithIDs:(NSArray *)IDs usingBlock:(QBPagedUsersBlock)block;

/** 
 Clearing Contact list
 */
- (void)clearData;


#pragma mark - Configurations

- (NSMutableDictionary *)friendsAsDictionaryFromFriendsArray:(NSArray *)friendsArray;
- (NSArray *)personsFromDictionaries:(NSArray *)dictionaries;
- (BOOL)isFriend:(QBUUser *)user;
- (QBUUser *)findFriendWithID:(NSUInteger)userID;

- (QBUUser *)searchFriendFromChatDialog:(QBChatDialog *)chatDialog;
- (NSArray *)searchFriendsFromChatDialog:(QBChatDialog *)chatDialog;

- (QBContactListItem *)contactItemFromContactListForOpponentID:(NSUInteger)opponentID;

@end
