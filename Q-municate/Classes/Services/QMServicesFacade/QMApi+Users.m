//
//  QMApi+Users.m
//  Qmunicate
//
//  Created by Andrey on 03.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMApi.h"
#import "QMUsersService.h"

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
    for (NSString *userID in ids) {
        
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
        NSString *userID = [NSString stringWithFormat:@"%d", user.ID];
        [ids addObject:userID];
    }
    return [ids allObjects];
}

- (NSArray *)idsFromContactListItems {
    
    NSMutableArray *idsToFetch = [NSMutableArray new];
    NSArray *contactListItems = self.usersService.contactList;
    
    for (QBContactListItem *item in contactListItems) {
        NSString *stringID = [NSString stringWithFormat:@"%d", item.userID];
        [idsToFetch addObject:stringID];
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

- (NSArray *)friends {
    
    NSArray *ids = [self idsFromContactListItems];
    NSMutableArray *allFriends = [NSMutableArray array];
    
    for (NSString * friendID in ids) {
        QBUUser *user = [self userWithID:friendID.integerValue];
        if (user) {
            [allFriends addObject:user];
        }
    }
    
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


//- (void)updateUserAvatarFromFacebook:(QBUUserResultBlock)completion {
//
//    __weak __typeof(self)weakSelf = self;
//    [self.facebookService loadUserImageWithUserID:self.currentUser.facebookID completion:^(UIImage *fbImage) {
//
//        if (fbImage) {
////            [weakSelf updateUserAvatar:fbImage imageName:weakSelf.currentUser.facebookID completion:completion];
//        }
//    }];
//}

//- (void)updateUserAvatar:(UIImage *)image imageName:(NSString *)imageName completion:(QBUUserResultBlock)completion {
//
//    QMContent *content = [[QMContent alloc] init];
//    __weak __typeof(self)weakSelf = self;
//    [content uploadImage:image named:imageName completion:^(QBCFileUploadTaskResult *result) {
//
//        if ([weakSelf checkResult:result]) {
//
//            QBUUser *user = weakSelf.currentUser;
//            user.oldPassword = user.password;
//            user.website = [result.uploadedBlob publicUrl];
//
//            [weakSelf.authService updateUser:user withCompletion:^(QBUUserResult *updateResult) {
//
//                if ([weakSelf checkResult:updateResult]) {
//
//                    updateResult.user.password = weakSelf.currentUser.password;
//                    weakSelf.currentUser = updateResult.user;
//                }
//
//                if (completion) completion(updateResult);
//            }];
//        }
//    }];
//}

@end
