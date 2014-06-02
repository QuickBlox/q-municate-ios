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

@property (copy, nonatomic) QBResultBlock resultBlock;

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
        NSError *error = [NSError errorWithDomain:@"No friends found in roaster" code:1100 userInfo:nil];
        
        // out with error:
        completion(NO, error);
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
    NSError *error = [NSError errorWithDomain:@"No friends found in roaster" code:1100 userInfo:nil];
    
    // block invoke:
    completion(NO, error);
}

#pragma mark -
#pragma mark - TERMINATE LOGIC

// *********************** FIND FRIENDS ****************************

- (void)retrieveFriendsFromFacebookWithCompletion:(QBChatResultBlock)resultBlock
{
     FBRequest *friendsRequest = [FBRequest requestForMyFriends];
    [friendsRequest startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
         
        NSMutableArray *myFriends = [(FBGraphObject *)result objectForKey:kData];
        if ([myFriends count] == 0) {
            resultBlock(NO);
            return;
        }
        NSMutableArray *friendsIDs = [self IDsOfFacebookUsers:myFriends];
        
        [self retrieveUsersWithFacebookIDs:friendsIDs usingBlock:^(NSArray *users, BOOL success, NSError *error) {
            if (success) {
                // we should to send contact requests to those users:
#warning TODO:
            }
        }];
    }];
}
                
- (NSMutableArray *)friendsIDsAndBaseIDsFromObjects:(NSArray *)objects
{
    NSMutableArray *IDs = [NSMutableArray new];
    NSMutableDictionary *baseIDs = [NSMutableDictionary new];
    
    for (QBCOCustomObject *object in objects) {
        NSString *friendID = object.fields[kFriendId];
        [IDs addObject:friendID];
        baseIDs[friendID] = object.ID;
    }
    // save custom object IDs:
    self.baseUserIDs = baseIDs;
    
    return IDs;
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


- (void)findAndAddAllFriendsForFacebookUserWithCompletion:(QBChatResultBlock)block
{
    [self retrieveIDsOfFriendsUsingBlock:^(Result *result) {
        if (result.success && [result isKindOfClass:[QBCOCustomObjectPagedResult class]]) {
            NSArray *objects = ((QBCOCustomObjectPagedResult *)result).objects;
            if ([objects count] != 0) {
                
                NSMutableArray *friendsIDs = [self friendsIDsAndBaseIDsFromObjects:objects];
                
                [self retrieveUsersWithIDs:friendsIDs usingBlock:^(Result *result) {
                    if (result.success && [result isKindOfClass:[QBUUserPagedResult class]]) {
                        NSArray *users = ((QBUUserPagedResult *)result).users;
                        self.friendsAsDictionary = [self friendsAsDictionaryFromFriendsArray:users];
                        block(YES);
                        return;
                    }
                }];
                
                return;
            }
            [self retrieveFriendsFromFacebookWithCompletion:^(BOOL success) {
                if (success) {
                    block(YES);
                    return;
                }
                block(NO);
            }];
        }
    }];
}

// ******************** ADD / REMOVE FRIENDS ***********************

- (void)addUserToFriendList:(QBUUser *)user completion:(QBChatResultBlock)block
{
    __weak QMContactList *weakSelf = self;
    
    [self addUserWithID:user.ID completion:^(Result *result) {
        if (result.success && [result isKindOfClass:[QBCOCustomObjectResult class]]) {
            QBCOCustomObject *object = ((QBCOCustomObjectResult *)result).object;
            
            // add user to friends list
            weakSelf.friendsAsDictionary[[@(user.ID) stringValue]] = user;
            // add baseID to baseIDs
            weakSelf.baseUserIDs[object.fields[kFriendId]] = object.ID;
            
            block(YES);
            return;
        }
        block(NO);
    }];
}

- (void)addUsersToFriends:(NSArray *)users
{
    __weak QMContactList *weakSelf = self;
    for (QBUUser *user in users) {
        [self addUserWithID:user.ID completion:^(Result *result) {
            if (result.success && [result isKindOfClass:[QBCOCustomObjectResult class]]) {
                QBCOCustomObject *object = ((QBCOCustomObjectResult *)result).object;
                // add baseID to baseIDs
                weakSelf.baseUserIDs[object.fields[kFriendId]] = object.ID;
            }
        }];
    }
}

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


#pragma mark - API
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

@end
