//
//  QMFacebook.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 1/8/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMFacebook.h"

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@implementation QMFacebook

NSString *const kQMHomeUrl = @"http://q-municate.com";
NSString *const kQMLogoUrl = @"https://files.quickblox.com/ic_launcher.png";
NSString *const kQMAppName = @"Q-municate";
NSString *const kQMDataKey = @"data";

static NSString *const kFBGraphGetPictureFormat = @"https://graph.facebook.com/%@/picture?height=100&width=100&access_token=%@";

+ (BFTask *)connect {
    
    BFTaskCompletionSource* source = [BFTaskCompletionSource taskCompletionSource];
    
    FBSDKAccessToken *session = [FBSDKAccessToken currentAccessToken];
    
    if (!session) {
        
        UINavigationController *navigationController = (UINavigationController *)[[UIApplication sharedApplication].windows.firstObject rootViewController];
        
        FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
        [loginManager logInWithReadPermissions:@[@"email", @"public_profile", @"user_friends"]
                            fromViewController:navigationController
                                       handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
                                           
                                           if (error) {
                                               
                                               [source setError:error];
                                           }
                                           else if (result.isCancelled) {
                                               
                                               [source cancel];
                                               
                                           }
                                           else {
                                               
                                               [source setResult:result.token.tokenString];
                                           }
                                       }];
    }
    else {
        
        [source setResult:session.tokenString];
    }
    
    return source.task;
}

+ (void)fetchMyFriends:(void(^)(NSArray *facebookFriends))completion {
    
    if ([FBSDKAccessToken currentAccessToken]) {
        FBSDKGraphRequest *friendsRequest = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me/friends" parameters:nil];
        
        [friendsRequest startWithCompletionHandler:^(FBSDKGraphRequestConnection *__unused connection, id result, NSError *error) {
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

+ (NSURL *)userImageUrlWithUserID:(NSString *)userID {
    
    FBSDKAccessToken *session = [FBSDKAccessToken currentAccessToken];
    NSString *urlString = [NSString stringWithFormat:kFBGraphGetPictureFormat, userID, session.tokenString];
    NSURL *url = [NSURL URLWithString:urlString];
    return url;
}

+ (BFTask *)loadMe {
    
    BFTaskCompletionSource* source = [BFTaskCompletionSource taskCompletionSource];
    
    FBSDKGraphRequest *friendsRequest = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:nil];
    
    [friendsRequest startWithCompletionHandler:^(FBSDKGraphRequestConnection *__unused connection, id result, NSError *error) {
        
        error != nil ? [source setError:error] : [source setResult:result];
    }];
    
    return source.task;
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

@end
