//
//  QMApi+Facebook.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 9/24/15.
//  Copyright © 2015 Quickblox. All rights reserved.
//

#import "QMApi.h"
#import "QMFacebook.h"

@implementation QMApi (Facebook)

- (void)fbFriends:(void(^)(NSArray *fbFriends))completion {
//    [QMFacebookService connectToFacebook:^(NSString *sessionToken) {
//        [QMFacebookService fetchMyFriends:completion];
//    }];
}

- (NSURL *)fbUserImageURLWithUserID:(NSString *)userID {
    return [QMFacebook userImageUrlWithUserID:userID];
}

- (void)fbLogout {
    [QMFacebook logout];
}

- (void)fbInviteDialogWithDelegate:(id<FBSDKAppInviteDialogDelegate>)delegate {
    
    [QMFacebook inviteFriendsWithDelegate:delegate];
}

@end
