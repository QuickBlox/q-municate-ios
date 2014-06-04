//
//  QBStorage.m
//  Q-municate
//
//  Created by Igor Alefirenko on 14/02/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMContactList.h"
#import "QMPerson.h"
#import "NSMutableDictionary+addQBUsersFromArray.h"

@interface QMContactList () <QBActionStatusDelegate>

@end


@implementation QMContactList


+ (instancetype)shared {
    static id storageInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        storageInstance = [[self alloc] init];
    });
    return storageInstance;
}

- (id)init
{
    if (self = [super init]) {
        self.allUsersAsDictionary = [NSMutableDictionary new];
    }
    return self;
}


#pragma mark - FRIEND LIST ROASTER

- (void)retriveFriendsWithContactListInfo:(QBContactList *)contactList completion:(void (^)(BOOL success, NSError *error))completion
{
    if ([contactList.contacts count] == 0) {
        completion(YES, nil);
        return;
    }
    // searching IDs of users out of Friends list:
    NSMutableArray *IDsToFetchFromQuickblox = [NSMutableArray new];
    
    for (QBContactListItem *record in contactList.contacts) {
        
        NSString *userID = [@(record.userID) stringValue];
        QBUUser *friend = self.friendsAsDictionary[userID];
        if (friend == nil) {
            [IDsToFetchFromQuickblox addObject:userID];
        }
    }
    if ([IDsToFetchFromQuickblox count] > 0) {
        // retrive users with ids:
        [self retrieveUsersWithIDs:IDsToFetchFromQuickblox usingBlock:^(NSArray *users, BOOL success, NSError *error) {
            // add to dictionary:
            if (success) {
                // if friends dict is empty:
                if (self.friendsAsDictionary == nil || [self.friendsAsDictionary count] == 0) {
                    self.friendsAsDictionary = [self friendsAsDictionaryFromFriendsArray:users];
                } else {
                    [self.friendsAsDictionary addUsersFromArray:users];
                }
                
                // friends added, out with success:
                completion(YES, nil);
                return;
            }
            
            // out with error from server:
            completion(NO, error);
        }];
        return;
    }
    // block invoke:
    completion(YES, nil);
}


// *********************** FIND FRIENDS FROM FACEBOOK ****************************

- (void)retrieveFriendsFromFacebookWithCompletion:(QBPagedUsersBlock)block
{
    [self fetchFriendsFromFacebookWithCompletion:^(NSArray *users, BOOL success, NSError *error) {
        if (!success) {
            // out with error:
            block(nil, NO, error);
            return;
        }
        if ([users count] == 0) {
            block(users, YES, nil);
            return;
        }
        NSMutableArray *friendsIDs = [self IDsOfFacebookUsers:users];
        
        [self retrieveUsersWithFacebookIDs:friendsIDs usingBlock:^(NSArray *users, BOOL success, NSError *error) {
            if (!success) {
                block(nil, NO, error);
                return;
            }
            block(users, YES, nil);
        }];
    }];
}


#pragma mark - API

// ******************** Facebook Friends ***********************


- (void)fetchFriendsFromFacebookWithCompletion:(QBPagedUsersBlock)handler
{
    FBRequest *friendsRequest = [FBRequest requestForMyFriends];
    [friendsRequest startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (error) {
            handler(nil, NO, error);
            return;
        }
        NSArray *myFriends = [(FBGraphObject *)result objectForKey:kData];
        handler(myFriends, YES, nil);
    }];
}

//**************************** API *********************************

- (void)retrieveUsersWithFullName:(NSString *)fullName usingBlock:(QBPagedUsersBlock)block
{
    QBResultBlock resultBlock = ^(Result *result) {
        if (result.success && [result isKindOfClass:QBUUserPagedResult.class]) {
            NSArray *users = ((QBUUserPagedResult *)result).users;
            block(users, YES, nil);
            return;
        }
        block(nil, NO, result.errors[0]);
    };
    [QBUsers usersWithFullName:fullName delegate:self context:Block_copy((__bridge void *)(resultBlock))];
}

- (void)retrieveUserWithID:(NSUInteger)userID completion:(void(^)(QBUUser *user, NSError *error))completion
{
    QBResultBlock block = ^(Result *result){
        if (result.success && [result isKindOfClass:[QBUUserResult class]]) {
            QBUUser *user = ((QBUUserResult *)result).user;
            self.allUsersAsDictionary[[@(user.ID) stringValue]] = user;
            completion(user, nil);
            return;
        }
        completion(nil, result.errors[0]);
    };
    
    [QBUsers userWithID:userID delegate:self context:Block_copy((__bridge void *)(block))];
}

- (void)retrieveUsersWithIDs:(NSArray *)IDs usingBlock:(QBPagedUsersBlock)block
{
    NSString *stringOfIDs = [[NSString alloc] init];
    for (NSString *ID in IDs) {
        if ([ID isEqual:[IDs firstObject]]) {
            stringOfIDs = [stringOfIDs stringByAppendingString:ID];
        } else {
            stringOfIDs = [stringOfIDs stringByAppendingString:[NSString stringWithFormat:@",%@", ID]];
        }
    }
    QBResultBlock resultBlock = ^(Result *result) {
        if (result.success && [result isKindOfClass:QBUUserPagedResult.class]) {
            NSArray *users = ((QBUUserPagedResult *)result).users;
            block(users, YES, nil);
            return;
        }
        block(nil, NO, result.errors[0]);
    };
    
    [QBUsers usersWithIDs:stringOfIDs delegate:self context:Block_copy((__bridge void *)(resultBlock))];
}

- (void)retrieveUsersWithFacebookIDs:(NSArray *)facebookIDs usingBlock:(QBPagedUsersBlock)block
{
    QBResultBlock resultBlock = ^(Result *result) {
        if (result.success && [result isKindOfClass:QBUUserPagedResult.class]) {
            NSArray *users = ((QBUUserPagedResult *)result).users;
            block(users, YES, nil);
            return;
        }
        block(nil, NO, result.errors[0]);
    };
    [QBUsers usersWithFacebookIDs:facebookIDs delegate:self context:Block_copy((__bridge void *)(resultBlock))];
}

- (void)retrieveUsersWithEmails:(NSArray *)emails usingBlock:(QBPagedUsersBlock)block
{
    QBResultBlock resultBlock = ^(Result *result) {
        if (result.success && [result isKindOfClass:QBUUserPagedResult.class]) {
            NSArray *users = ((QBUUserPagedResult *)result).users;
            block(users, YES, nil);
            return;
        }
        block(nil, NO, result.errors[0]);
    };
    [QBUsers usersWithEmails:emails delegate:self context:Block_copy((__bridge void *)(resultBlock))];
}


#pragma mark - QBActionStatusDelegate

- (void)completedWithResult:(Result *)result context:(void *)contextInfo
{
    ((__bridge void (^)(Result * result))(contextInfo))(result);
    Block_release(contextInfo);
}


#pragma mark - Configurations

- (NSMutableDictionary *)friendsAsDictionaryFromFriendsArray:(NSArray *)friendsArray
{
    NSMutableDictionary *dictionaryOfUsers = [NSMutableDictionary new];
    for (QBUUser *user in friendsArray) {
        dictionaryOfUsers[[@(user.ID) stringValue]] = user;
    }
    return dictionaryOfUsers;
}

- (NSArray *)personsFromDictionaries:(NSArray *)dictionaries
{
    NSMutableArray *persons = [[NSMutableArray alloc] init];
    NSString *token = [FBSession activeSession].accessTokenData.accessToken;
    
    for (NSDictionary *dict in dictionaries) {
        QMPerson *person = [[QMPerson alloc] init];
        
        person.firstName = dict[@"first_name"];
        person.lastName = dict[@"last_name"];
        person.fullName = dict[@"name"];
        person.ID = dict[@"id"];
        person.status = kFacebookFriendStatus;
        person.imageURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?height=400&width=400&access_token=%@", dict[@"id"], token];
        [persons addObject:person];
    }
    return persons;
}

- (BOOL)isFriend:(QBUUser *)user
{
    QBUUser *friend = self.friendsAsDictionary[[@(user.ID) stringValue]];
    if (friend == nil) {
        return NO;
    }
    return YES;
}

- (QBUUser *)findFriendWithID:(NSUInteger)userID
{
    QBUUser *friend = self.friendsAsDictionary[[@(userID) stringValue]];
    if (friend == nil) {
        return nil;
    }
    return friend;
}

- (NSMutableArray *)IDsOfFacebookUsers:(NSArray *)facebookUsers
{
    NSMutableArray *IDs = [[NSMutableArray alloc] init];
    for (NSDictionary *facebookUser in facebookUsers) {
        [IDs addObject:facebookUser[kId]];
    }
    return IDs;
}

- (void)clearData
{
    self.me = nil;
    self.friendsAsDictionary = nil;
    self.baseUserIDs = nil;
    self.searchedUsers = nil;
    self.facebookFriendsToInvite = nil;
	self.facebookMe = nil;
	self.contactsToInvite = nil;
}

- (QBUUser *)searchFriendFromChatDialog:(QBChatDialog *)chatDialog
{
    QBUUser *currentUser = nil;
    for (NSString *ID in chatDialog.occupantIDs) {
        currentUser = self.friendsAsDictionary[ID];
        if (currentUser != nil) {
            return currentUser;
        }
    }
    return nil;
}

- (NSArray *)searchFriendsFromChatDialog:(QBChatDialog *)chatDialog
{
    NSMutableArray *friends = [NSMutableArray new];
    for (NSString *ID in chatDialog.occupantIDs) {
        QBUUser *currentUser = self.friendsAsDictionary[ID];
        if (currentUser != nil) {
            [friends addObject:currentUser];
        }
    }
    return friends;
}

- (QBContactListItem *)contactItemFromContactListForOpponentID:(NSUInteger)opponentID
{
    QBContactList *contactList = [QBChat instance].contactList;
    for (QBContactListItem *item in contactList.contacts) {
        if (item.userID == opponentID) {
            return item;
        }
    }
    return nil;
}

@end
