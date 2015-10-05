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

- (void)fbLogout {
    [QMFacebookService logout];
}

- (void)fbInviteDialogWithDelegate:(id<FBSDKAppInviteDialogDelegate>)delegate {
    
    [QMFacebookService inviteFriendsWithDelegate:delegate];
}

@end
