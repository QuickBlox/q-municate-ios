//
//  QMFacebook.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 1/8/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMFacebook.h"

// facebook kit
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

static NSString * const kFBGraphGetPictureFormat = @"https://graph.facebook.com/%@/picture?height=100&width=100&access_token=%@";

@implementation QMFacebook

+ (BFTask *)connect {
    
    BFTaskCompletionSource *source = [BFTaskCompletionSource taskCompletionSource];
    
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

+ (void)logout {
    
    FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
    [loginManager logOut];
}

@end
