//
//  QMApi+Users.m
//  Qmunicate
//
//  Created by Andrey on 03.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMApi.h"
#import "QMUsersService.h"

@interface QMApi()

@property (strong, nonatomic) QBContactList *contactList;
@property (strong, nonatomic) NSMutableDictionary *usersMemoryCache;

@end

@implementation QMApi (Users)

- (void)retrieveUsersWithIDs:(NSArray *)idsToFetch completion:(void(^)(BOOL updated))completion {

    NSArray *filteredIDs = [self checkExistIds:idsToFetch];
    
    if (filteredIDs.count == 0) {
        completion(NO);
    } else {
        
        PagedRequest *pagedRequest = [[PagedRequest alloc] init];
        pagedRequest.page = 1;
        pagedRequest.perPage = filteredIDs.count < 100 ? filteredIDs.count : 100;
        
        __weak __typeof(self)weakSelf = self;
        [self.usersService retrieveUsersWithIDs:filteredIDs pagedRequest:pagedRequest completion:^(QBUUserPagedResult *pagedResult) {
            [weakSelf addUsers:pagedResult.users];
            completion(YES);
        }];
    }
}

- (void)retrieveUsersIfNeededWithContactList:(QBContactList *)contactList completion:(void(^)(BOOL updated))completion {
    
    NSArray *occupantIDs = [self idsFromContactList:contactList];
    [self retrieveUsersWithIDs:occupantIDs completion:completion];
}

- (void)retrieveUsersForChatDialog:(QBChatDialog *)chatDialog completion:(void(^)(BOOL updated))completion {
    
    [self retrieveUsersWithIDs:chatDialog.occupantIDs completion:completion];
}

- (BOOL)addUserInContactListWithUserID:(NSUInteger)userID {
    return [[QBChat instance] addUserToContactListRequest:userID];
}

/**
 @param QBUUser ID
 @return QBContactListItem from chaced contactList
 */

- (QBContactListItem *)contactItemWithUserID:(NSUInteger)userID {
    
    NSArray *contacts = [self contactListItemsWithContactList:self.contactList];
    for (QBContactListItem *item in contacts) {
        if (item.userID == userID) {
            return item;
        }
    }
    
    return nil;
}

- (NSArray *)checkExistIds:(NSArray *)ids {
    
    NSMutableSet *idsToFetch = [NSMutableSet setWithArray:ids];
    for (NSString *userID in ids) {
        
        QBUUser *user = self.usersMemoryCache[userID];
        if (user) {
            [idsToFetch removeObject:userID];
        }
    }
    
    return [idsToFetch allObjects];
}

- (NSArray *)idsFromContactList:(QBContactList *)contactList {
    
    NSMutableArray *idsToFetch = [NSMutableArray new];
    NSArray *contactListItems = [self contactListItemsWithContactList:contactList];
    
    for (QBContactListItem *item in contactListItems) {
        NSString *stringID = [NSString stringWithFormat:@"%d", item.userID];
        [idsToFetch addObject:stringID];
    }
    
    return idsToFetch;
}

- (NSArray *)contactListItemsWithContactList:(QBContactList *)contactList {
    
    NSMutableArray *contactListItems = [NSMutableArray arrayWithArray:contactList.contacts];
    [contactListItems addObjectsFromArray:contactList.pendingApproval];
    
    return contactListItems;
}

- (void)addUsers:(NSArray *)users {
    
    for (QBUUser *user in users) {
        [self addUser:user];
    }
}

- (void)addUser:(QBUUser *)user {
    
    NSString *key = [NSString stringWithFormat:@"%d", user.ID];
    self.usersMemoryCache[key] = user;
}

- (QBUUser *)userWithID:(NSUInteger)userID {
    
    NSString *stingID = [NSString stringWithFormat:@"%d", userID];
    QBUUser *user = self.usersMemoryCache[stingID];
    
    return user;
}

- (NSArray *)allFriends {
    
    NSArray *ids = [self idsFromContactList:self.contactList];
    NSMutableArray *allFriends = [NSMutableArray array];
    
    for (NSString * friendID in ids) {
        QBUUser *user = self.usersMemoryCache[friendID];
        if (user) {
            [allFriends addObject:user];
        }
    }
    
    return allFriends;
}

@end
