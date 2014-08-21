//
//  QMApi+Facebook.m
//  Qmunicate
//
//  Created by Andrey Ivanov on 10.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMApi.h"
#import "QMFacebookService.h"

@implementation QMApi (Facebook)

- (void)fbFriends:(void(^)(NSArray *fbFriends))completion {
    [QMFacebookService connectToFacebook:^(NSString *sessionToken) {
        [QMFacebookService fetchMyFriends:completion];
    }];
}

- (NSURL *)fbUserImageURLWithUserID:(NSString *)userID {
    return [QMFacebookService userImageUrlWithUserID:userID];
}

- (void)fbInviteUsersWithIDs:(NSArray *)ids copmpletion:(void(^)(NSError *error))completion {

    NSString *strIds = [ids componentsJoinedByString:@","];
    [QMFacebookService shareToUsers:strIds completion:completion];
}

- (void)fbLogout {
    [QMFacebookService logout];
}

- (void)fbIniviteDialogWithCompletion:(void(^)(BOOL success))completion {
    
    [QMFacebookService connectToFacebook:^(NSString *sessionToken) {
        [QMFacebookService inviteFriendsWithCompletion:completion];
    }];
}

@end
