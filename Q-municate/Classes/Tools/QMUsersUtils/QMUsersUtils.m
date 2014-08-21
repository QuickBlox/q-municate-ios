//
//  QMUsersUtils.m
//  Q-municate
//
//  Created by Igor Alefirenko on 21.08.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMUsersUtils.h"

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

@end
