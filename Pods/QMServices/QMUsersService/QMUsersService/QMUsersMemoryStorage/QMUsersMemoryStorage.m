//
//  QMUsersMemoryStorage.m
//  QMServices
//
//  Created by Andrey on 26.11.14.
//  Copyright (c) 2015 Quickblox Team. All rights reserved.
//

#import "QMUsersMemoryStorage.h"

static NSString *const kQMQBUUserIDKeyPath = @"ID";
static NSString *const kQMQBUUserLoginKeyPath = @"login";
static NSString *const kQMQBUUserEmailKeyPath = @"email";
static NSString *const kQMQBUUserFacebookIDKeyPath = @"facebookID";
static NSString *const kQMQBUUserTwitterIDKeyPath = @"twitterID";
static NSString *const kQMQBUUserExternalUserIDKeyPath = @"externalUserID";

const struct QMUsersSearchKeyStruct QMUsersSearchKey = {
    .foundObjects = @"kFoundObjects",
    .notFoundSearchValues = @"notFoundSearchValues"
};

@interface QMUsersMemoryStorage()

@property (strong, nonatomic) NSMutableDictionary *users;

@end

@implementation QMUsersMemoryStorage

- (instancetype)init {
    
    self = [super init];
    if (self) {
        
        _users = [NSMutableDictionary dictionary];
    }
    
    return self;
}

- (void)addUser:(QBUUser *)user {
    
    NSString *key = [NSString stringWithFormat:@"%tu", user.ID];
    QBUUser *existingUser = self.users[key];
    if ([existingUser.lastRequestAt compare:user.lastRequestAt] == NSOrderedDescending) {
        // always should have newest date
        user.lastRequestAt = existingUser.lastRequestAt;
    }
    self.users[key] = user;
}

- (void)addUsers:(NSArray *)users {
    
    [users enumerateObjectsUsingBlock:^(QBUUser *user, NSUInteger idx, BOOL *stop) {
        
        [self addUser:user];
    }];
}

- (QBUUser *)userWithID:(NSUInteger)userID {
    
   // NSParameterAssert(userID > 0);
    
    NSString *stingID = [NSString stringWithFormat:@"%tu", userID];
    QBUUser *user = self.users[stingID];
    
    return user;
}

- (QBUUser *)userWithExternalID:(NSUInteger)externalUserID {
    
    return [self usersWithExternalIDs:@[@(externalUserID)]].firstObject;
}

- (NSArray *)usersWithIDs:(NSArray *)ids {
    
    NSMutableArray *allFriends = [NSMutableArray arrayWithCapacity:ids.count];
    
    for (NSNumber * friendID in ids) {
        
        QBUUser *user = [self userWithID:friendID.integerValue];
        
        if (user) {
            
            [allFriends addObject:user];
        }
    }
    
    return allFriends.copy;
}

- (NSArray *)idsWithUsers:(NSArray *)users {
    
    NSMutableSet *ids = [NSMutableSet setWithCapacity:users.count];
    for (QBUUser *user in users) {
        
        [ids addObject:@(user.ID)];
    }
    
    return [ids allObjects];
}

- (NSArray *)unsortedUsers {
    
    NSArray *allUsers = self.users.allValues;
    return allUsers;
}

- (NSArray *)usersSortedByKey:(NSString *)key ascending:(BOOL)ascending {
    
    NSArray *allUsers = self.users.allValues;
    
    NSSortDescriptor *sorter =
    [[NSSortDescriptor alloc] initWithKey:key
                                ascending:ascending
                                 selector:@selector(localizedCaseInsensitiveCompare:)];
    
    NSArray *sortedUsers = [allUsers sortedArrayUsingDescriptors:@[sorter]];
    
    return sortedUsers;
}

- (NSArray *)contactsSortedByKey:(NSString *)key ascending:(BOOL)ascending {
    
    NSArray *conatctsIDs = [self.delegate contactsIDS];
    NSArray *contacts = [self usersWithIDs:conatctsIDs];
    
    NSSortDescriptor *sorter =
    [[NSSortDescriptor alloc] initWithKey:key
                                ascending:ascending
                                 selector:@selector(localizedCaseInsensitiveCompare:)];
    
    NSArray *sortedContacts = [contacts sortedArrayUsingDescriptors:@[sorter]];
    
    return sortedContacts;
}

//MARK: - Utils

- (NSArray *)usersWithIDs:(NSArray *)IDs withoutID:(NSUInteger)ID {
    
    NSMutableArray *withoutMeIDs = IDs.mutableCopy;
    [withoutMeIDs removeObject:@(ID)];
    
    NSArray *result = [self usersWithIDs:withoutMeIDs];
    return result;
}

- (NSString *)joinedNamesbyUsers:(NSArray *)users {
    
    NSMutableArray *components = [NSMutableArray arrayWithCapacity:users.count];
    
    for (QBUUser *user in users) {
        [components addObject:user.fullName];
    }
    
    NSString *result = [components componentsJoinedByString:@", "];
    return result;
}

//MARK: - QMMemoryStorageProtocol

- (void)free {
    
    [self.users removeAllObjects];
}

//MARK: - Fetch

- (NSArray *)usersForKeypath:(NSString *)keypath withValues:(NSArray *)values {
    
    NSPredicate *predicate =
    [NSPredicate predicateWithBlock:^BOOL(QBUUser *evaluatedObject,
                                          NSDictionary *bindings) {
        return [values containsObject:[evaluatedObject valueForKeyPath:keypath]];
    }];
    
    return [self.users.allValues filteredArrayUsingPredicate: predicate];
}

- (NSArray *)usersWithExternalIDs:(NSArray *)externalUserIDs {
    
    return [self usersForKeypath:kQMQBUUserExternalUserIDKeyPath
                      withValues:externalUserIDs];
}

- (NSArray *)usersWithLogins:(NSArray *)logins {
    
    return [self usersForKeypath:kQMQBUUserLoginKeyPath
                      withValues:logins];
}

- (NSArray *)usersWithEmails:(NSArray *)emails {
    
    return [self usersForKeypath:kQMQBUUserEmailKeyPath
                      withValues:emails];
}

- (NSArray *)usersWithFacebookIDs:(NSArray *)facebookIDs {
    
    return [self usersForKeypath:kQMQBUUserFacebookIDKeyPath
                      withValues:facebookIDs];
}

- (NSArray *)usersWithTwitterIDs:(NSArray *)twitterIDs {
    
    return [self usersForKeypath:kQMQBUUserTwitterIDKeyPath
                      withValues:twitterIDs];
}

//MARK: - Filter

- (NSDictionary *)valuesForKeypath:(NSString *)keypath
                 byExcludingValues:(NSArray *)values {
    
    NSParameterAssert(values);
    NSMutableArray *mutableValues = [values mutableCopy];
    
    
    NSPredicate *predicate =
    [NSPredicate predicateWithBlock:^BOOL(QBUUser *evaluatedObject,
                                          NSDictionary *bindings) {
        
        BOOL contains = [values containsObject:[evaluatedObject valueForKeyPath:keypath]];
        if (contains) {
            [mutableValues removeObject:[evaluatedObject valueForKeyPath:keypath]];
        }
        return contains;
    }];
    
    NSArray *foundUsers =
    [self.users.allValues filteredArrayUsingPredicate:predicate];
    
    return @{
             QMUsersSearchKey.foundObjects : foundUsers,
             QMUsersSearchKey.notFoundSearchValues : mutableValues.copy
             };
}

- (NSDictionary *)usersByExcludingUsersIDs:(NSArray *)ids {
    
    return [self valuesForKeypath:kQMQBUUserIDKeyPath
                byExcludingValues:ids];
}

- (NSDictionary *)usersByExcludingLogins:(NSArray *)logins {
    
    return [self valuesForKeypath:kQMQBUUserLoginKeyPath
                byExcludingValues:logins];
}

- (NSDictionary *)usersByExcludingEmails:(NSArray *)emails {
    
    return [self valuesForKeypath:kQMQBUUserEmailKeyPath
                byExcludingValues:emails];
}

- (NSDictionary *)usersByExcludingFacebookIDs:(NSArray *)facebookIDs {
    
    return [self valuesForKeypath:kQMQBUUserFacebookIDKeyPath
                byExcludingValues:facebookIDs];
}

- (NSDictionary *)usersByExcludingTwitterIDs:(NSArray *)twitterIDs {
    
    return [self valuesForKeypath:kQMQBUUserTwitterIDKeyPath
                byExcludingValues:twitterIDs];
}

@end
