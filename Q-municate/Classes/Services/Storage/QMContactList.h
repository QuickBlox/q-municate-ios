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

// FIND FRIENDS
- (void)retrieveFriendsUsingBlock:(QBChatResultBlock)block;
- (void)retrieveFriendsFromFacebookWithCompletion:(QBChatResultBlock)resultBlock;
- (void)retrieveUsersWithFullName:(NSString *)fullName completion:(QBChatResultBlock)block;
- (void)retrieveUsersWithEmails:(NSArray *)emails usingBlock:(QBResultBlock)block;
- (void)retrieveUserWithID:(NSUInteger)userID completion:(void(^)(QBUUser *user, NSError *error))completion;
- (void)findAndAddAllFriendsForFacebookUserWithCompletion:(QBChatResultBlock)block;

// ADD / REMOVE FRIENDS
- (void)addUserToFriendList:(QBUUser *)user completion:(QBChatResultBlock)block;
- (void)addUserWithID:(NSUInteger)ID completion:(QBResultBlock)block;

- (void)removeUserFromFriendList:(QBUUser *)user completion:(QBChatResultBlock)block;


// REQUEST FOR FRIENDS TO FACEBOOK:
- (void)fetchFriendsFromFacebookWithCompletion:(FBResultBlock)handler;

// Clear all data:
- (void)clearData;

#pragma mark - Configurations

- (NSArray *)personsFromDictionaries:(NSArray *)dictionaries;
- (BOOL)isFriend:(QBUUser *)user;
- (QBUUser *)findFriendWithID:(NSUInteger)userID;

- (QBUUser *)searchFriendFromChatDialog:(QBChatDialog *)chatDialog;
- (NSArray *)searchFriendsFromChatDialog:(QBChatDialog *)chatDialog;

@end
