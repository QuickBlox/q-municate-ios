//
//  QMUsersService.h
//  Q-municate
//
//  Created by Igor Alefirenko on 14/02/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QMUsersService : NSObject

- (void)retrieveUsersWithContactListInfo:(QBContactList *)contactList completion:(QBUUserPagedResultBlock)completion;
- (void)retrieUsersWithPagedRequest:(PagedRequest *)pagedRequest completion:(QBUUserPagedResultBlock)completion;
- (void)retrieveUsersWithFullName:(NSString *)fullName completion:(QBUUserPagedResultBlock)completion;
- (void)retrieveUserWithID:(NSUInteger)userID completion:(QBUUserResultBlock)completion;
- (void)retrieveUsersWithEmails:(NSArray *)emails completion:(QBUUserPagedResultBlock)completion;

@end
