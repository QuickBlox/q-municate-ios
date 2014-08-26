//
//  QMUsersService.m
//  Q-municate
//
//  Created by Igor Alefirenko on 14/02/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMUsersService.h"
#import "QBEchoObject.h"
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
        
    }
    return self;
}

- (void)start {
    [super start];
    
    __weak __typeof(self)weakSelf = self;
    [[QMChatReceiver instance] chatContactListDidChangeWithTarget:self block:^(QBContactList *contactList) {
        
        [weakSelf.contactList removeAllObjects];
        
        [weakSelf.contactList addObjectsFromArray:contactList.pendingApproval];
        [weakSelf.contactList addObjectsFromArray:contactList.contacts];
        
        [weakSelf retrieveUsersWithIDs:[weakSelf idsFromContactListItems] completion:^(BOOL updated) {
            
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


- (void)stop {
    [super stop];
    
    [[QMChatReceiver instance] unsubscribeForTarget:self];
    [self.users removeAllObjects];
    [self.contactList removeAllObjects];
}

- (QBUUser *)userWithID:(NSUInteger)userID {
    
    NSString *stingID = [NSString stringWithFormat:@"%d", userID];
    QBUUser *user = self.users[stingID];
    return user;
}

- (void)addUsers:(NSArray *)users {
    
    for (QBUUser *user in users) {
        [self addUser:user];
    }
    
    [[QMChatReceiver instance] postUsersHistoryUpdated];
}

- (void)addUser:(QBUUser *)user {
    
    NSString *key = [NSString stringWithFormat:@"%d", user.ID];
    self.users[key] = user;
}

#pragma mark - FRIEND LIST ROASTER

- (NSObject<Cancelable> *)retrieveUsersWithFacebookIDs:(NSArray *)facebookIDs completion:(QBUUserPagedResultBlock)completion {
    return [QBUsers usersWithFacebookIDs:facebookIDs delegate:[QBEchoObject instance] context:[QBEchoObject makeBlockForEchoObject:completion]];
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

- (void)retrieveUsersWithIDs:(NSArray *)idsToFetch completion:(void(^)(BOOL updated))completion {
    
    NSArray *filteredIDs = [self checkExistIds:idsToFetch];
    ILog(@"RetrieveUsers %@", filteredIDs);
    
    if (filteredIDs.count == 0) {
        completion(NO);
    } else {
        
        PagedRequest *pagedRequest = [[PagedRequest alloc] init];
        pagedRequest.page = 1;
        pagedRequest.perPage = filteredIDs.count < 100 ? filteredIDs.count : 100;
        
        __weak __typeof(self)weakSelf = self;
        [self retrieveUsersWithIDs:filteredIDs pagedRequest:pagedRequest completion:^(QBUUserPagedResult *pagedResult) {
            [weakSelf addUsers:pagedResult.users];
            completion(YES);
        }];
    }
}

- (NSObject<Cancelable> *)retrieveUsersWithIDs:(NSArray *)ids pagedRequest:(PagedRequest *)pagedRequest completion:(QBUUserPagedResultBlock)completion {
    
    NSString *joinedIds = [ids componentsJoinedByString:@","];
    [self.retrivedIds addObjectsFromArray:ids];
    
    __weak __typeof(self)weakSelf = self;
    QBUUserPagedResultBlock resultBlock = ^(QBUUserPagedResult *pagedResult) {
        
        for (QBUUser *user in pagedResult.users) {
            [weakSelf.retrivedIds removeObject:@(user.ID)];
        }
        completion(pagedResult);
    };
    
    return [QBUsers usersWithIDs:joinedIds pagedRequest:pagedRequest
                        delegate:[QBEchoObject instance]
                         context:[QBEchoObject makeBlockForEchoObject:resultBlock]];
}

- (NSObject<Cancelable> *)retrieveUsersWithPagedRequest:(PagedRequest*)pagedRequest completion:(QBUUserPagedResultBlock)completion {
    
    return [QBUsers usersWithPagedRequest:pagedRequest
                                 delegate:[QBEchoObject instance]
                                  context:[QBEchoObject makeBlockForEchoObject:completion]];
}

- (NSObject<Cancelable> *)retrieveUsersWithFullName:(NSString *)fullName pagedRequest:(PagedRequest *)pagedRequest completion:(QBUUserPagedResultBlock)completion {
    
    return [QBUsers usersWithFullName:fullName
                         pagedRequest:pagedRequest
                             delegate:[QBEchoObject instance]
                              context:[QBEchoObject makeBlockForEchoObject:completion]];
}

- (NSObject<Cancelable> *)retrieveUserWithID:(NSUInteger)userID completion:(QBUUserResultBlock)completion {
    
    return [QBUsers userWithID:userID
                      delegate:[QBEchoObject instance]
                       context:[QBEchoObject makeBlockForEchoObject:completion]];
}

- (NSObject<Cancelable> *)retrieveUsersWithEmails:(NSArray *)emails completion:(QBUUserPagedResultBlock)completion {
    
    return [QBUsers usersWithEmails:emails
                           delegate:[QBEchoObject instance]
                            context:[QBEchoObject makeBlockForEchoObject:completion]];
}

- (NSObject<Cancelable> *)resetUserPasswordWithEmail:(NSString *)email completion:(QBResultBlock)completion {

    return [QBUsers resetUserPasswordWithEmail:email delegate:[QBEchoObject instance] context:[QBEchoObject makeBlockForEchoObject:completion]];
}

- (NSObject<Cancelable> *)updateUser:(QBUUser *)user withCompletion:(QBUUserResultBlock)completion {
    
    return [QBUsers updateUser:user delegate:[QBEchoObject instance] context:[QBEchoObject makeBlockForEchoObject:completion]];
}

@end
