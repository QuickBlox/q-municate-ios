//
//  QMUsersUtils.m
//  Q-municate
//
//  Created by Igor Alefirenko on 21.08.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMUsersUtils.h"
#import <QBUUser+CustomData.h>

@implementation QMUsersUtils


+ (NSArray *)sortUsersByFullname:(NSArray *)users
{    
    NSSortDescriptor *sorter = [[NSSortDescriptor alloc]
                                initWithKey:@"fullName"
                                ascending:YES
                                selector:@selector(localizedCaseInsensitiveCompare:)];
    NSArray *sortedUsers = [users sortedArrayUsingDescriptors:@[sorter]];
    
    return sortedUsers;
}

+ (NSMutableArray *)filteredUsers:(NSArray *)users withFlterArray:(NSArray *)usersToFilter
{
    NSMutableArray *filteredUsrs = users.mutableCopy;
    for (QBUUser *usr in users) {
        for (QBUUser *filterUsr in usersToFilter) {
            if (filterUsr.ID == usr.ID) {
                [filteredUsrs removeObject:usr];
            }
        }
    }
    return filteredUsrs;
}

+ (NSURL *)userAvatarURL:(QBUUser *)user {
    NSURL *url = [NSURL URLWithString:user.avatarUrl];
    return url;
}

+ (NSArray *)idsOfUsers:(NSArray *)users {
    
    NSMutableArray *ids = [NSMutableArray array];
    
    for (QBUUser *user in users) {
        
        [ids addObject:@(user.ID)];
    }
    
    return ids.copy;
}

@end
