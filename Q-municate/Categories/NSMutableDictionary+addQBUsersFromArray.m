//
//  NSMutableDictionary+addQBUsersFromArray.m
//  Q-municate
//
//  Created by Igor Alefirenko on 02/06/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "NSMutableDictionary+addQBUsersFromArray.h"

@implementation NSMutableDictionary (addQBUsersFromArray)

- (void)addUsersFromArray:(NSArray *)usersArray
{
    for (QBUUser *user in usersArray) {
        self[[@(user.ID) stringValue]] = user;
    }
}

@end
