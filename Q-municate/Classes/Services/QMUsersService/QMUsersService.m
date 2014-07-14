//
//  QMUsersService.m
//  Q-municate
//
//  Created by Igor Alefirenko on 14/02/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMUsersService.h"
#import "QBEchoObject.h"

@implementation QMUsersService

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

@end
