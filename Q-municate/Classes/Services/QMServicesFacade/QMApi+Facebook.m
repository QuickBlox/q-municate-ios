//
//  QMApi+Facebook.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 9/24/15.
//  Copyright © 2015 Quickblox. All rights reserved.
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
    
    [QMFacebookService inviteFriendsWithCompletion:completion];
}

@end
