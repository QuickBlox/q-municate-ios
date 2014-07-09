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
    
    if (idsToFetch.count == 0) {
        completion(NO);
    } else {
        
        PagedRequest *pagedRequest = [[PagedRequest alloc] init];
        pagedRequest.page = 1;
        pagedRequest.perPage = idsToFetch.count < 100 ? idsToFetch.count : 100;
        
        __weak __typeof(self)weakSelf = self;
        [self.usersService retrieveUsersWithIDs:idsToFetch pagedRequest:pagedRequest completion:^(QBUUserPagedResult *pagedResult) {
            [weakSelf addUsers:pagedResult.users];
            completion(YES);
        }];
    }
}

- (void)retrieveUsersIfNeededWithContactList:(QBContactList *)contactList completion:(void(^)(BOOL updated))completion {
    
    NSArray *occupantIDs = [self idsFromContactList:contactList];
    NSArray *idsToFetch = [self idsToFetchWithIDs:occupantIDs];
    [self retrieveUsersWithIDs:idsToFetch completion:completion];
}

- (void)retrieveUsersForChatDialog:(QBChatDialog *)chatDialog completion:(void(^)(BOOL updated))completion {
    
    NSArray *idsToFetch = [self idsToFetchWithIDs:chatDialog.occupantIDs];
    [self retrieveUsersWithIDs:idsToFetch completion:completion];
}

- (BOOL)addUserInContactListWithUserID:(NSUInteger)userID {
    return [[QBChat instance] addUserToContactListRequest:userID];
}

/**
 @param QBUUser ID
 @return QBContactListItem from chaced contactList
 */

- (QBContactListItem *)contactItemWithUserID:(NSUInteger)userID {
    
    for (QBContactListItem *item in self.contactList.contacts) {
        if (item.userID == userID) {
            return item;
        }
    }
    
    return nil;
}

- (NSArray *)idsToFetchWithIDs:(NSArray *)ids {
    
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
    NSMutableArray *contacts = [NSMutableArray arrayWithArray:contactList.contacts];
    [contacts addObjectsFromArray:contactList.pendingApproval];
    
    for (QBContactListItem *item in contacts) {
        NSString *stringID = [NSString stringWithFormat:@"%d", item.userID];
        [idsToFetch addObject:stringID];
    }
    
    return idsToFetch;
}

- (NSArray *)contactListItems {
    
    QBContactList *contactList = self.contactList;
    NSMutableArray *contactListItems = [NSMutableArray arrayWithArray:contactList.contacts];
    [contactListItems addObjectsFromArray:contactList.pendingApproval];
    
    return contactListItems;
}

- (BOOL)checkIDInCurrentContactListContactList:(NSUInteger)userID exist:(BOOL (^)(QBContactListItem *contactItem))exist {
    
    BOOL check = NO;
    NSArray *contacts = [self contactListItems];
    for (QBContactListItem *contactListItem in contacts) {
        if (contactListItem.userID == userID) {
            check = exist(contactListItem);
            break;
        }
    }
    
    return check;
}

- (BOOL)isFriedID:(NSUInteger)userID {
    
    return [self checkIDInCurrentContactListContactList:userID exist:^BOOL(QBContactListItem *contactItem) {
        return YES;
    }];
}

- (BOOL)onlineStatusForFriendID:(NSUInteger)userID {
    
    return [self checkIDInCurrentContactListContactList:userID exist:^BOOL(QBContactListItem *contactItem) {
        return contactItem.online;
    }];
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
    NSArray *friends = [self.usersMemoryCache objectsForKeys:ids notFoundMarker:[NSNull null]];
    
    return friends;
}

@end
