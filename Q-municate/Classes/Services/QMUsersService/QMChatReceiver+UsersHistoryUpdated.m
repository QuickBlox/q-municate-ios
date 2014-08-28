//
//  QMChatReceiver+UsersHistoryUpdated.m
//  Q-municate
//
//  Created by Andrey on 11.08.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMChatReceiver.h"

@implementation QMChatReceiver (UsersHistoryUpdated)

- (void)postUsersHistoryUpdated {
    
    [self executeBloksWithSelector:_cmd enumerateBloks:^(QMUsersHistoryUpdated block) {
        block();
    }];
}

- (void)usersHistoryUpdatedWithTarget:(id)target block:(QMUsersHistoryUpdated)block {
    [self subsribeWithTarget:target selector:@selector(postUsersHistoryUpdated) block:block];
}

- (void)contactRequestUsersListChanged
{
    [self executeBloksWithSelector:_cmd enumerateBloks:^(QMUsersHistoryUpdated block) {
        block();
    }];
}

- (void)contactRequestUsersListChangedWithTarget:(id)target block:(QMUsersHistoryUpdated)block {
    [self subsribeWithTarget:target selector:@selector(contactRequestUsersListChanged) block:block];
}


@end
