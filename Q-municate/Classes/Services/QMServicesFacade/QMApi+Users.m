//
//  QMApi+Users.m
//  Qmunicate
//
//  Created by Andrey Ivanov on 03.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMApi.h"
#import "QMUsersService.h"
#import "QMContentService.h"

@implementation QMApi (Users)

- (void)retrieveUsersWithIDs:(NSArray *)idsToFetch completion:(void(^)(BOOL updated))completion {
    
    NSArray *filteredIDs = [self checkExistIds:idsToFetch];
    NSLog(@"RetrieveUsers %@", filteredIDs);
    
    if (filteredIDs.count == 0) {
        completion(NO);
    } else {
        
        PagedRequest *pagedRequest = [[PagedRequest alloc] init];
        pagedRequest.page = 1;
        pagedRequest.perPage = filteredIDs.count < 100 ? filteredIDs.count : 100;
        
        __weak __typeof(self)weakSelf = self;
        [self.usersService retrieveUsersWithIDs:filteredIDs pagedRequest:pagedRequest completion:^(QBUUserPagedResult *pagedResult) {
            [weakSelf.usersService addUsers:pagedResult.users];
            completion(YES);
        }];
    }
}

- (void)retrieveFriendsIfNeeded:(void(^)(BOOL updated))completion {
    
    NSArray *friendsIDs = [self idsFromContactListItems];
    [self retrieveUsersWithIDs:friendsIDs completion:completion];
}

- (void)retrieveUsersForChatDialog:(QBChatDialog *)chatDialog completion:(void(^)(BOOL updated))completion {
    
    [self retrieveUsersWithIDs:chatDialog.occupantIDs completion:completion];
}

- (BOOL)addUserToContactListRequest:(NSUInteger)userID {
    
    BOOL success = [[QBChat instance] addUserToContactListRequest:userID];
    return success;
}

- (BOOL)removeUserFromContactListWithUserID:(NSUInteger)userID {
    
    BOOL success = [[QBChat instance] removeUserFromContactList:userID];
    return success;
}

- (BOOL)confirmAddContactRequest:(NSUInteger)userID {
    
    BOOL success = [[QBChat instance] confirmAddContactRequest:userID];
    return success;
}

- (BOOL)rejectAddContactRequest:(NSUInteger)userID {
    
    BOOL success =[[QBChat instance] rejectAddContactRequest:userID];
    return success;
}

/**
 @param QBUUser ID
 @return QBContactListItem from chaced contactList
 */

- (QBContactListItem *)contactItemWithUserID:(NSUInteger)userID {
    
    NSArray *contacts = self.usersService.contactList;
    for (QBContactListItem *item in contacts) {
        
        if (item.userID == userID) {
            return item;
        }
    }
    
    return nil;
}

- (NSArray *)checkExistIds:(NSArray *)ids {
    
    NSMutableSet *idsToFetch = [NSMutableSet setWithArray:ids];
    
    for (NSNumber *userID in ids) {
        
        QBUUser *user = [self userWithID:userID.integerValue];
        if (user) {
            [idsToFetch removeObject:userID];
        }
    }
    
    return [idsToFetch allObjects];
}

- (NSArray *)idsWithUsers:(NSArray *)users {

    NSMutableSet *ids = [NSMutableSet set];
    for (QBUUser *user in users) {
        [ids addObject:@(user.ID)];
    }
    return [ids allObjects];
}

- (NSArray *)idsFromContactListItems {
    
    NSMutableArray *idsToFetch = [NSMutableArray new];
    NSArray *contactListItems = self.usersService.contactList;
    
    for (QBContactListItem *item in contactListItems) {
        [idsToFetch addObject:@(item.userID)];
    }
    
    return idsToFetch;
}

- (NSArray *)contactListItemsWithContactList:(QBContactList *)contactList {
    
    NSUInteger count = contactList.pendingApproval.count + contactList.contacts.count;
    NSMutableArray *contactListItems = [NSMutableArray arrayWithCapacity:count];
    [contactListItems addObjectsFromArray:contactList.contacts];
    [contactListItems addObjectsFromArray:contactList.pendingApproval];
    
    return contactListItems;
}

- (QBUUser *)userWithID:(NSUInteger)userID {
    return [self.usersService userWithID:userID];
}

- (NSArray *)usersWithIDs:(NSArray *)ids {

    NSMutableArray *allFriends = [NSMutableArray array];
    for (NSNumber * friendID in ids) {
        QBUUser *user = [self userWithID:friendID.integerValue];
        if (user) {
            [allFriends addObject:user];
        }
    }
    
    return allFriends;
}

- (NSArray *)friends {
    
    NSArray *ids = [self idsFromContactListItems];
    NSArray *allFriends = [self usersWithIDs:ids];
    
    return allFriends;
}

#pragma mark - Update current User

- (void)updateUser:(QBUUser *)user completion:(void(^)(BOOL success))completion  {
    
    NSString *password = user.password;
    user.password = nil;
    
    __weak __typeof(self)weakSelf = self;
    [self.usersService updateUser:user withCompletion:^(QBUUserResult *result) {
        
        if ([weakSelf checkResult:result]) {
            result.user.password = password;
            weakSelf.currentUser = result.user;
        }
        
        completion(result.success);
    }];
}

- (void)changePasswordForCurrentUser:(QBUUser *)currentUser completion:(void(^)(BOOL success))completion {
    
    [self updateUser:currentUser completion:^(BOOL success) {
        completion(success);
    }];
}

- (void)updateUser:(QBUUser *)user image:(UIImage *)image progress:(QMContentProgressBlock)progress completion:(void (^)(BOOL success))completion {
    
    __weak __typeof(self)weakSelf = self;

    __block QBUUser *userInfo = user;
    void (^updateUserProfile)(NSString *) =^(NSString *publicUrl) {

        if (!userInfo) {
            userInfo = weakSelf.currentUser;
        }
        
        if (publicUrl.length > 0) {
            userInfo.website = publicUrl;
        }
        [weakSelf updateUser:userInfo completion:completion];
    };
    
    if (image) {
        [self.contentService uploadPNGImage:image progress:progress completion:^(QBCFileUploadTaskResult *result) {
            updateUserProfile(result.uploadedBlob.publicUrl);
        }];
    }
    else {
        updateUserProfile(nil);
    }
}

- (void)updateUser:(QBUUser *)user imageUrl:(NSURL *)imageUrl progress:(QMContentProgressBlock)progress completion:(void (^)(BOOL success))completion {
    [self.contentService downloadFileWithUrl:imageUrl completion:^(NSData *data) {
        if (data) {
            UIImage *image = [UIImage imageWithData:data];
            [self updateUser:user image:image progress:progress completion:completion];
        }
    }];
}

@end
