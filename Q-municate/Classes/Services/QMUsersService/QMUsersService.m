//
//  QMUsersService.m
//  Q-municate
//
//  Created by Igor Alefirenko on 14/02/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMUsersService.h"
#import "QMChatReceiver.h"

@interface QMUsersService()

@property (strong, nonatomic) NSMutableDictionary *users;
@property (strong, nonatomic) NSMutableSet *retrivedIds;

@end

@implementation QMUsersService

- (instancetype)init {
    
    self = [super init];
    if (self) {
        self.users = [NSMutableDictionary dictionary];
        self.contactList = [NSMutableArray array];
        self.retrivedIds = [NSMutableSet set];
        self.friendsOnly = [NSMutableArray array];
        self.contactListPendingApproval = [NSMutableArray array];
        
    }
    return self;
}

- (void)start {
    [super start];
    
    self.confirmRequestUsersIDs = [NSMutableSet new];
    __weak __typeof(self)weakSelf = self;
    [[QMChatReceiver instance] chatContactListDidChangeWithTarget:self block:^(QBContactList *contactList) {
        
        if (!contactList) {
            return;
        }
        [weakSelf.contactList removeAllObjects];
        [weakSelf.friendsOnly removeAllObjects];
        [weakSelf.contactListPendingApproval removeAllObjects];
        
        [weakSelf.contactListPendingApproval addObjectsFromArray:contactList.pendingApproval];
        
        [weakSelf.contactList addObjectsFromArray:contactList.pendingApproval];
        [weakSelf.contactList addObjectsFromArray:contactList.contacts];
        [weakSelf.friendsOnly addObjectsFromArray:contactList.contacts];
        
        [weakSelf retrieveUsersWithIDs:[weakSelf idsFromContactListItems] completion:^(BOOL updated) {
            
        }];
    }];
        
    [[QMChatReceiver instance] chatDidReceiveContactAddRequestWithTarget:self block:^(NSUInteger userID) {
        
        [weakSelf.confirmRequestUsersIDs addObject:@(userID)];
        [weakSelf retriveIfNeededUserWithID:userID completion:^(BOOL retrieveWasNeeded) {
            
            [[QMChatReceiver instance] contactRequestUsersListChanged];
        }];
    }];
}

- (NSArray *)idsFromContactListItems {
    
    NSMutableArray *idsToFetch = [NSMutableArray new];
    NSArray *contactListItems = self.contactList;
    
    for (QBContactListItem *item in contactListItems) {
        [idsToFetch addObject:@(item.userID)];
    }
    
    return idsToFetch;
}

- (NSArray *)idsOfContactsOnly {
    
    NSMutableSet *IDs = [NSMutableSet new];
    NSArray *contactItems = [QBChat instance].contactList.contacts;
    
    for (QBContactListItem *item in contactItems) {
        [IDs addObject:@(item.userID)];
    }
    
    for (QBContactListItem *item in [QBChat instance].contactList.pendingApproval) {
        
        if (item.subscriptionState == QBPresenseSubscriptionStateFrom) {
            [IDs addObject:@(item.userID)];
        }
    }
    return IDs.allObjects;
}


- (void)stop {
    [super stop];
    
    [[QMChatReceiver instance] unsubscribeForTarget:self];
    [self.users removeAllObjects];
    [self.contactList removeAllObjects];
    [self.friendsOnly removeAllObjects];
}

- (NSArray *)idsOfUsers:(NSArray *)users
{
    NSMutableSet *usersIDs = [NSMutableSet new];
    for (QBUUser *usr in users) {
        [usersIDs addObject:@(usr.ID)];
    }
    return usersIDs.allObjects;
}

- (QBUUser *)userWithID:(NSUInteger)userID {
    
    NSString *stingID = [NSString stringWithFormat:@"%zd", userID];
    QBUUser *user = self.users[stingID];
    return user;
}

- (BOOL)isFriendWithID:(NSUInteger)ID
{
    NSArray *contactListItems = self.friendsOnly;
    for (QBContactListItem *item in contactListItems) {
        if (item.userID == ID) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)isContactRequestWithID:(NSInteger)ID
{
    NSArray *contactRequestsArray = [self.confirmRequestUsersIDs.allObjects copy];
    for (NSNumber *contactRequestID in contactRequestsArray) {
        if (ID == contactRequestID.intValue) {
            return YES;
        }
    }
    return NO;
}

- (void)addUsers:(NSArray *)users {
    
    for (QBUUser *user in users) {
        [self addUser:user];
    }
    
    [[QMChatReceiver instance] postUsersHistoryUpdated];
}

- (void)addUser:(QBUUser *)user {
    
    NSString *key = [NSString stringWithFormat:@"%zd", user.ID];
    self.users[key] = user;
}

- (void)deleteUser:(QBUUser *)user
{
    NSString *key = [NSString stringWithFormat:@"%zd", user.ID];
    [self.users removeObjectForKey:key];
}

- (BOOL)deleteContactRequestUserID:(NSUInteger)contactUserID
{
    if ([self.confirmRequestUsersIDs.allObjects containsObject:@(contactUserID)]) {
        [self.confirmRequestUsersIDs removeObject:@(contactUserID)];
        return YES;
    }
    return NO;
}

// friend request has not been accepted yet
- (BOOL)userIDIsInPendingList:(NSUInteger)userId{
    for( QBContactListItem *item in [self contactListPendingApproval] ){
        if( userId == item.userID ){
            return YES;
        }
    }
    return NO;
}

#pragma mark - 

- (void)retriveIfNeededUserWithID:(NSUInteger)userID completion:(void(^)(BOOL retrieveWasNeeded))completionBlock
{
    QBUUser *user = [self userWithID:userID];
    if (!user) {
        [self retrieveUserWithID:userID completion:^(QBResponse *response, QBUUser *retrievedUser) {
            //
            if (response.success) {
                if (completionBlock) completionBlock(YES);
                return;
            }
            if (completionBlock) completionBlock(NO);
        }];
        return;
    }
    completionBlock(NO);
}

- (void)retriveIfNeededUsersWithIDs:(NSArray *)usersIDs completion:(void(^)(BOOL retrieveWasNeeded))completionBlock
{
    NSArray *idsToFetch = [self usersIDsToFetch:usersIDs];
    if (idsToFetch.count > 0) {
        [self retriveUsersWithIDs:idsToFetch completion:^(QBResponse *response, QBGeneralResponsePage *page, NSArray *users) {
            if (response.success) {
                if (completionBlock) completionBlock(YES);
                return;
            }
            if (completionBlock) completionBlock(NO);
        }];
        return;
    }
    if (completionBlock) completionBlock(NO);
}


- (QBRequest *)retrieveUsersWithFacebookIDs:(NSArray *)facebookIDs completion:(QBUUserPagedResponseBlock)completion {
    NSUInteger currentPage = 1;
    NSUInteger perPage = facebookIDs.count < 100 ? facebookIDs.count : 100;
    return [QBRequest usersWithFacebookIDs:facebookIDs page:[QBGeneralResponsePage responsePageWithCurrentPage:currentPage perPage:perPage] successBlock:^(QBResponse *response, QBGeneralResponsePage *page, NSArray *users) {
        //
        completion(response,page,users);
    } errorBlock:^(QBResponse *response) {
        //
        completion(response,nil,nil);
    }];
}

- (NSArray *)checkExistIds:(NSArray *)ids {
    
    NSMutableSet *idsToFetch = [NSMutableSet setWithArray:ids];
    
    for (NSNumber *userID in ids) {
        
        QBUUser *user = [self userWithID:userID.integerValue];
        BOOL inProgress = [self.retrivedIds containsObject:userID];
        
        if (user || inProgress) {
            [idsToFetch removeObject:userID];
        }
    }
    
    return [idsToFetch allObjects];
}

- (NSArray *)usersIDsToFetch:(NSArray *)IDs
{
    NSMutableSet *idsToFetch = [NSMutableSet new];
    
    for (NSNumber *ID in IDs) {
        QBUUser *usr = [self userWithID:ID.integerValue];
        if (!usr) {
            [idsToFetch addObject:ID];
        }
    }
    return idsToFetch.allObjects;
}

- (void)retrieveUsersWithIDs:(NSArray *)idsToFetch completion:(void(^)(BOOL updated))completion {
    
    NSArray *filteredIDs = [self checkExistIds:idsToFetch];
    ILog(@"RetrieveUsers %@", filteredIDs);
    
    if (filteredIDs.count == 0) {
        completion(NO);
    } else {
        
        NSUInteger currentPage = 1;
        NSUInteger perPage = filteredIDs.count < 100 ? filteredIDs.count : 100;
        QBGeneralResponsePage *pagedRequest = [QBGeneralResponsePage responsePageWithCurrentPage:currentPage perPage:perPage];
        
        __weak __typeof(self)weakSelf = self;
        [self retrieveUsersWithIDs:filteredIDs pagedRequest:pagedRequest completion:^(QBResponse *response, QBGeneralResponsePage *page, NSArray *users) {
            [weakSelf addUsers:users];
            completion(YES);
        }];
    }
}

- (QBRequest *)retrieveUsersWithIDs:(NSArray *)ids pagedRequest:(QBGeneralResponsePage *)pagedRequest completion:(QBUUserPagedResponseBlock)completion {
    
    [self.retrivedIds addObjectsFromArray:ids];
    
    __weak __typeof(self)weakSelf = self;
    return [QBRequest usersWithIDs:ids page:pagedRequest successBlock:^(QBResponse *response, QBGeneralResponsePage *page, NSArray *users) {
        //
        for (QBUUser *user in users) {
            [weakSelf.retrivedIds removeObject:@(user.ID)];
        }
        completion(response,page,users);
    } errorBlock:^(QBResponse *response) {
        //
        completion(response,nil,nil);
    }];
}

//- (QBRequest *)retrieveUsersWithPagedRequest:(QBGeneralResponsePage*)pagedRequest completion:(QBUUserPagedResponseBlock)completion {
//    
//    
//    return [QBUsers usersWithPagedRequest:pagedRequest
//                                 delegate:[QBEchoObject instance]
//                                  context:[QBEchoObject makeBlockForEchoObject:completion]];
//}

- (QBRequest *)retrieveUsersWithFullName:(NSString *)fullName pagedRequest:(QBGeneralResponsePage *)pagedRequest completion:(QBUUserPagedResponseBlock)completion {
    
    return [QBRequest usersWithFullName:fullName page:pagedRequest successBlock:^(QBResponse *response, QBGeneralResponsePage *page, NSArray *users) {
        //
        completion(response,page,users);
    } errorBlock:^(QBResponse *response) {
        //
        completion(response,nil,nil);
    }];
}

- (QBRequest *)retrieveUserWithID:(NSUInteger)userID completion:(QBUUserResponseBlock)completion {
    
    __weak __typeof(self)weakSelf = self;
    QBUUserResponseBlock responseBlock = ^(QBResponse *response, QBUUser *user) {
        if (response.success) {
            [weakSelf addUser:user];
        }
        completion(response,user);
    };
    
    return [QBRequest userWithID:userID successBlock:responseBlock
                      errorBlock:^(QBResponse *response) {
                          //
                          completion(response,nil);
            }];
}
         
- (QBRequest *)retriveUsersWithIDs:(NSArray *)usersIDs completion:(QBUUserPagedResponseBlock)completion
{
    __weak __typeof(self)weakSelf = self;
    QBUUserPagedResponseBlock responseBlock = ^(QBResponse *response, QBGeneralResponsePage *page, NSArray *users) {
        if (response.success) {
            [weakSelf addUsers:users];
        }
        completion(response,page,users);
    };

    return [QBRequest usersWithIDs:usersIDs page:[QBGeneralResponsePage responsePageWithCurrentPage:1 perPage:100] successBlock:responseBlock
                        errorBlock:^(QBResponse *response) {
                            //
                            completion(response,nil,nil);
            }];
}

- (QBRequest *)retrieveUsersWithEmails:(NSArray *)emails completion:(QBUUserPagedResponseBlock)completion {
    
    return [QBRequest usersWithEmails:emails successBlock:^(QBResponse *response, QBGeneralResponsePage *page, NSArray *users) {
        //
        completion(response,page,users);
    } errorBlock:^(QBResponse *response) {
        //
        completion(response,nil,nil);
    }];
}

- (QBRequest *)resetUserPasswordWithEmail:(NSString *)email completion:(QBResponseBlock)completion {

    return [QBRequest resetUserPasswordWithEmail:email successBlock:^(QBResponse *response) {
        //
        completion(response);
    } errorBlock:^(QBResponse *response) {
        //
        completion(response);
    }];
}

- (QBRequest *)updateCurrentUser:(QBUpdateUserParameters *)params withCompletion:(QBUUserResponseBlock)completion {
    
    return [QBRequest updateCurrentUser:params successBlock:^(QBResponse *response, QBUUser *updatedUser) {
        //
        completion(response,updatedUser);
    } errorBlock:^(QBResponse *response) {
        //
        completion(response,nil);
    }];
}

@end
