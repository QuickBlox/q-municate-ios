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

@end

@implementation QMUsersService

- (instancetype)init {
    
    self = [super init];
    if (self) {
        self.users = [NSMutableDictionary dictionary];
        self.contactList = [NSMutableArray array];
    }
    return self;
}

- (void)start {
    
    __weak __typeof(self)weakSelf = self;
    [[QMChatReceiver instance] chatContactListDidChangeWithTarget:self block:^(QBContactList *contactList) {
        [weakSelf.contactList removeAllObjects];
        [weakSelf.contactList addObjectsFromArray:contactList.pendingApproval];
        [weakSelf.contactList addObjectsFromArray:contactList.contacts];
    }];
}

- (void)destroy {
    
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
}

- (void)addUser:(QBUUser *)user {
    
    NSString *key = [NSString stringWithFormat:@"%d", user.ID];
    self.users[key] = user;
}

#pragma mark - FRIEND LIST ROASTER

- (NSObject<Cancelable> *)retrieveUsersWithFacebookIDs:(NSArray *)facebookIDs completion:(QBUUserPagedResultBlock)completion {
    return [QBUsers usersWithFacebookIDs:facebookIDs delegate:[QBEchoObject instance] context:[QBEchoObject makeBlockForEchoObject:completion]];
}

- (NSObject<Cancelable> *)retrieveUsersWithIDs:(NSArray *)ids pagedRequest:(PagedRequest *)pagedRequest completion:(QBUUserPagedResultBlock)completion {
    NSString *joinedIds = [ids componentsJoinedByString:@","];
    return [QBUsers usersWithIDs:joinedIds pagedRequest:pagedRequest
                        delegate:[QBEchoObject instance]
                         context:[QBEchoObject makeBlockForEchoObject:completion]];
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
