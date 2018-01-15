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

static NSString * const kQMHomeUrl = @"http://q-municate.com";
static NSString * const kQMLogoUrl = @"https://files.quickblox.com/ic_launcher.png";
static NSString * const kQMAppName = @"Q-municate";
static NSString * const kQMDataKey = @"data";

static NSString * const kFBGraphGetPictureFormat =
@"https://graph.facebook.com/%@/picture?height=100&width=100&access_token=%@";

@implementation QMFacebook

+ (BFTask *)connect {
    
    FBSDKAccessToken *session = [FBSDKAccessToken currentAccessToken];
    
    if (!session) {
        
        UINavigationController *navigationController =
        (id)[[UIApplication sharedApplication].windows.firstObject rootViewController];
        
        NSArray *readPermissions =
        @[@"email", @"public_profile", @"user_friends"];
        
        FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
        
        return make_task(^(BFTaskCompletionSource * _Nonnull source) {
            
            [loginManager logInWithReadPermissions:readPermissions
                                fromViewController:navigationController
                                           handler:^(FBSDKLoginManagerLoginResult *result, NSError *error)
             {
                 
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
            
        });
    }
    else {
        
        /*
         Handling an Invalidated Session.
         
         We cannot know if the cached Facebook session is valid until we attempt to make a request to the API.
         A session can become invalidated if a user changes their password or revokes the application's privileges.
         When this happens, the user needs to be logged out. We can identify an invalid session error within a FBSDKGraphRequest completion
         handler.
         
         If the request fails, we can check if it was due to an invalid session by:
         if ([error.userInfo[@"error"][@"type"] isEqualToString: @"OAuthException"])
         */
        
        return [[self loadMe] continueWithSuccessBlock:^id _Nullable(BFTask<NSDictionary *> * _Nonnull  __unused t) {
            return [BFTask taskWithResult:session.tokenString];
        }];
    }
}

+ (NSURL *)userImageUrlWithUserID:(NSString *)userID {
    
    FBSDKAccessToken *session = [FBSDKAccessToken currentAccessToken];
    NSString *urlString = [NSString stringWithFormat:kFBGraphGetPictureFormat, userID, session.tokenString];
    NSURL *url = [NSURL URLWithString:urlString];
    return url;
}

+ (BFTask *)loadMe {
    
    return make_task(^(BFTaskCompletionSource * _Nonnull source) {
        
        FBSDKGraphRequest *myInfoRequest =
        [[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:nil];
        
        [myInfoRequest startWithCompletionHandler:^(FBSDKGraphRequestConnection *__unused connection,
                                                    id result,
                                                    NSError *error)
         {
             error ? [source setError:error] : [source setResult:result];
         }];
    });
}

+ (void)logout {
    
    FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
    [loginManager logOut];
}

@end
