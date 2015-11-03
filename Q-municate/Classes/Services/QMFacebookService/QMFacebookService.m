//
//  QMFacebookService.m
//  Q-municate
//
//  Created by Igor Alefirenko on 26/03/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMFacebookService.h"

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@implementation QMFacebookService 

NSString *const kQMHomeUrl = @"http://q-municate.com";
NSString *const kQMLogoUrl = @"https://files.quickblox.com/ic_launcher.png";
NSString *const kQMAppName = @"Q-municate";
NSString *const kQMDataKey = @"data";

+ (void)fetchMyFriends:(void(^)(NSArray *facebookFriends))completion {
    
    if ([FBSDKAccessToken currentAccessToken]) {
        FBSDKGraphRequest *friendsRequest = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me/friends" parameters:nil];
        
        [friendsRequest startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
            NSArray *myFriends = error ? @[] : [result objectForKey:kQMDataKey];
            if (completion) completion(myFriends);
         }];
    } else {
        if (completion) completion(@[]);
    }
}

+ (void)fetchMyFriendsIDs:(void(^)(NSArray *facebookFriendsIDs))completion {
    
    [self fetchMyFriends:^(NSArray *facebookFriends) {
        
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:facebookFriends.count];
        
        for (NSDictionary *user in facebookFriends) {
            [array addObject:[user valueForKey:@"id"]];
        }
        if (completion) completion(array);
    }];
}

NSString *const kFBGraphGetPictureFormat = @"https://graph.facebook.com/%@/picture?height=100&width=100&access_token=%@";

+ (NSURL *)userImageUrlWithUserID:(NSString *)userID {

    FBSDKAccessToken *session = [FBSDKAccessToken currentAccessToken];
    NSString *urlString = [NSString stringWithFormat:kFBGraphGetPictureFormat, userID, session.tokenString];
    NSURL *url = [NSURL URLWithString:urlString];
    return url;
}

+ (void)loadMe:(void(^)(NSDictionary *user))completion {
    
    FBSDKGraphRequest *friendsRequest = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:nil];
    
    [friendsRequest startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
        //
        if (completion) completion(result);
    }];
}

+ (void)inviteFriendsWithDelegate:(id<FBSDKAppInviteDialogDelegate>)delegate {
    
    FBSDKAppInviteContent *content =[[FBSDKAppInviteContent alloc] init];
    content.appLinkURL = [NSURL URLWithString:kQMHomeUrl];
    content.appInvitePreviewImageURL = [NSURL URLWithString:kQMLogoUrl];
    
    // present the dialog. Assumes delegate implements protocol `FBSDKAppInviteDialogDelegate`
    [FBSDKAppInviteDialog showFromViewController:nil withContent:content delegate:delegate];
}

+ (void)logout {
    
    FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
    [loginManager logOut];
}

+ (void)connectToFacebook:(void(^)(NSString *sessionToken))completion {
    
    FBSDKAccessToken *session = [FBSDKAccessToken currentAccessToken];
    
    if (!session) {
        FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
        [loginManager
         logInWithReadPermissions: @[@"email", @"public_profile", @"user_friends"]
         handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
             if (error) {
                 NSLog(@"Process error");
             } else if (result.isCancelled) {
                 
                 if (completion) {
                     completion(nil);
                 }
                 
             } else {
                 if (completion) {
                     completion(result.token.tokenString);
                 }
             }
         }];
    }
    else {
        if (completion) completion(session.tokenString);
    }
}

@end
