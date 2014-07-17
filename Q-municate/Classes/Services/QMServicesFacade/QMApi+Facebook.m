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

    @weakify(self)
    [self.facebookService connectToFacebook:^(NSString *sessionToken) {
        @strongify(self)
        [self.facebookService fetchMyFriends:completion];
    }];
}

- (NSURL *)fbUserImageURLWithUserID:(NSString *)userID {
    return [self.facebookService userImageUrlWithUserID:userID];
}

- (void)fbInviteUsersWithIDs:(NSArray *)ids copmpletion:(void(^)(NSError *error))completion {

    NSString *strIds = [ids componentsJoinedByString:@","];
    [self.facebookService shareToUsers:strIds completion:completion];
}

- (void)fbLogout {
    [self.facebookService logout];
}

@end
