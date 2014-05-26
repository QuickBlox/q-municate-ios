//
//  QBStorage.m
//  Q-municate
//
//  Created by Igor Alefirenko on 14/02/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMContactList.h"
#import "QMPerson.h"

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
        
        [self retrieveUsersWithFacebookIDs:friendsIDs usingBlock:^(Result *result) {
            if (result.success && [result isKindOfClass:[QBUUserPagedResult class]]) {
                NSArray *facebookFriends = ((QBUUserPagedResult *)result).users;
                if ([facebookFriends count] == 0) {
                    resultBlock(NO);
                    return;
                }
                self.friendsAsDictionary = [self arrayToDictionary:facebookFriends];
                resultBlock(YES);
                [self addUsersToFriends:facebookFriends];  // include hardcode
            }
        }];

    }];
}

- (void)retrieveFriendsUsingBlock:(QBChatResultBlock)block
{
    [self retrieveIDsOfFriendsUsingBlock:^(Result *result) {
        if (result.success && [result isKindOfClass:[QBCOCustomObjectPagedResult class]]) {
            NSArray *customObjects = ((QBCOCustomObjectPagedResult *)result).objects;
            if ([customObjects count] == 0) {
                block(NO);
                return;
            }
            
            NSMutableArray *friendsIDs = [self friendsIDsAndBaseIDsFromObjects:customObjects];
            
            [self retrieveUsersWithIDs:friendsIDs usingBlock:^(Result *result) {
                if (result.success && [result isKindOfClass:[QBUUserPagedResult class]]) {
                    NSArray *friends = ((QBUUserPagedResult *)result).users;
                    self.friendsAsDictionary = [self arrayToDictionary:friends];
                    block(YES);
                }
            }];
        }
    }];
}

- (NSMutableDictionary *)arrayToDictionary:(NSArray *)array
{
    NSMutableDictionary *dictionaryOfUsers = [NSMutableDictionary new];
    for (QBUUser *user in array) {
        dictionaryOfUsers[[@(user.ID) stringValue]] = user;
    }
    return dictionaryOfUsers;
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

- (void)retrieveUsersWithFullName:(NSString *)fullName completion:(QBChatResultBlock)block
{
    [self retrieveUsersWithFullName:fullName usingBlock:^(Result *result) {
        if (result.success && [result isKindOfClass:[QBUUserPagedResult class]]) {
            NSArray *users = ((QBUUserPagedResult *)result).users;
            self.searchedUsers =  [self arrayToDictionary:users];
            block(YES);
            return;
        }
        block(NO);
    }];
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
                        self.friendsAsDictionary = [self arrayToDictionary:users];
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

- (void)removeUserFromFriendList:(QBUUser *)user completion:(QBChatResultBlock)block
{
    NSString *userID = [NSString stringWithFormat:@"%lu", (unsigned long)user.ID];
    NSString *baseID = self.baseUserIDs[userID];

    [self deleteUserWithID:baseID completion:^(Result *result) {
        if (result.success) {
            // delete user from CO:
            [self.baseUserIDs removeObjectForKey:userID];
            // delete user from friends:
            [self.friendsAsDictionary removeObjectForKey:[@(user.ID) stringValue]];
            block(YES);
            return;
        }
        block(NO);
    }];
}

- (void)fetchFriendsFromFacebookWithCompletion:(FBResultBlock)handler
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

- (void)retrieveIDsOfFriendsUsingBlock:(QBResultBlock)block
{
    _resultBlock = block;
    NSMutableDictionary *extendedRequest = [NSMutableDictionary new];
    extendedRequest[@"user_id"] = @(self.me.ID);
    extendedRequest[@"limit"] = @100;
    [QBCustomObjects objectsWithClassName:kClassName extendedRequest:extendedRequest delegate:self];
}

- (void)retrieveUsersWithFullName:(NSString *)fullName usingBlock:(QBResultBlock)block
{
    _resultBlock = block;
    [QBUsers usersWithFullName:fullName delegate:self];
}

- (void)retrieveUsersWithIDs:(NSArray *)IDs usingBlock:(QBResultBlock)block
{
    NSString *stringOfIDs = [[NSString alloc] init];
    for (NSString *ID in IDs) {
        if ([ID isEqual:[IDs firstObject]]) {
            stringOfIDs = [stringOfIDs stringByAppendingString:ID];
        } else {
            stringOfIDs = [stringOfIDs stringByAppendingString:[NSString stringWithFormat:@",%@", ID]];
        }
    }
    
    _resultBlock = block;
    [QBUsers usersWithIDs:stringOfIDs delegate:self];
}

- (void)retrieveUsersWithFacebookIDs:(NSArray *)facebookIDs usingBlock:(QBResultBlock)block
{
    _resultBlock = block;
    [QBUsers usersWithFacebookIDs:facebookIDs delegate:self];
}

- (void)retrieveUsersWithEmails:(NSArray *)emails usingBlock:(QBResultBlock)block
{
    _resultBlock = block;
    [QBUsers usersWithEmails:emails delegate:self];
}

- (void)retrieveAllUsersUsingBlock:(QBResultBlock)block
{
    _resultBlock = block;
    PagedRequest *pagedRequest = [PagedRequest request];
    pagedRequest.perPage = 100;
    [QBUsers usersWithPagedRequest:pagedRequest delegate:self];
}

// ************ ADD / REMOVE *************************
- (void)addUserWithID:(NSUInteger)ID completion:(QBResultBlock)block
{
    QBCOCustomObject *customObject = [QBCOCustomObject customObject];
    customObject.className = kClassName;
    customObject.fields[kFriendId] = @(ID);
    
    _resultBlock = block;
    [QBCustomObjects createObject:customObject delegate:self];
}

- (void)deleteUserWithID:(NSString *)baseID completion:(QBResultBlock)block
{
    _resultBlock = block;
    [QBCustomObjects deleteObjectWithID:baseID className:kClassName delegate:self];
}

#pragma mark - QBActionStatusDelegate

- (void)completedWithResult:(Result *)result
{
    _resultBlock(result);
}

- (void)completedWithResult:(Result *)result context:(void *)contextInfo
{
    ((__bridge void (^)(Result * result))(contextInfo))(result);
    Block_release(contextInfo);
}


#pragma mark - Configurations

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
