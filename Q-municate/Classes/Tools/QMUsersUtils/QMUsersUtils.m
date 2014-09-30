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

+ (NSURL *)userAvatarURL:(QBUUser *)user {
    NSURL *url = nil;
#warning Old avatar url logic changed!
    if (user.avatarURL) {
        url = [NSURL URLWithString:user.avatarURL];
    } else {
        url = [NSURL URLWithString:user.website];
    }
    return url;
}

@end
