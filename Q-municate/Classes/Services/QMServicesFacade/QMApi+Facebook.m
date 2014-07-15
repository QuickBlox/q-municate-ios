//
//  QMApi+Facebook.m
//  Qmunicate
//
//  Created by Andrey on 10.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMApi.h"
#import "QMFacebookService.h"

@implementation QMApi (Facebook)

- (void)fbFriends:(void(^)(NSArray *fbFriends))completion {

    __weak __typeof(self)weakSelf = self;
    [self.facebookService connectToFacebook:^(NSString *sessionToken) {
        [weakSelf.facebookService fetchMyFriends:completion];
    }];
}

- (NSURL *)fbUserImageURLWithUserID:(NSString *)userID {
    return [self.facebookService userImageUrlWithUserID:userID];
}

- (void)fbInviteUsersWithIDs:(NSArray *)ids copmpletion:(void(^)(void))completion {

    NSString *strIds = [ids componentsJoinedByString:@","];
    [self.facebookService shareToUsers:strIds completion:^(NSError *error) {
        completion();
    }];
}

- (void)fbLogout {
    [self.facebookService logout];
}

@end
