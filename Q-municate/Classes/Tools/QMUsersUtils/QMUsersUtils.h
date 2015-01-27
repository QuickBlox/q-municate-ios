//
//  QMUsersUtils.h
//  Q-municate
//
//  Created by Igor Alefirenko on 21.08.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QMUsersUtils : NSObject

+ (NSArray *)sortUsersByFullname:(NSArray *)users;
+ (NSMutableArray *)filteredUsers:(NSArray *)users withFlterArray:(NSArray *)usersToFilter;
+ (NSURL *)userAvatarURL:(QBUUser *)user;

@end
