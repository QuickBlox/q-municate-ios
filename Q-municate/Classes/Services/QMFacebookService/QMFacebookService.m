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

@interface QMFacebookService() <FBSDKAppInviteDialogDelegate>

@end

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
            completion(myFriends);
         }];
    }
}

+ (void)fetchMyFriendsIDs:(void(^)(NSArray *facebookFriendsIDs))completion {
    
    [self fetchMyFriends:^(NSArray *facebookFriends) {
        
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:facebookFriends.count];
        
        for (NSDictionary *user in facebookFriends) {
            [array addObject:[user valueForKey:@"ID"]];
        }
        completion(array);
    }];
}

+ (void)shareToUsers:(NSString *)usersIDs completion:(void(^)(NSError *error))completion {
    
    NSDictionary *postParams = @{
                                 @"link"        : kQMHomeUrl,
                                 @"picture"     : kQMLogoUrl,
                                 @"name"        : kQMAppName,
                                 @"caption"     : kQMAppName,
                                 @"description" : @"",
                                 @"place"       : @"155021662189",
                                 @"message"     : NSLocalizedString(@"QM_STR_DEAR_FRIEND", nil),
                                 @"tags"        : usersIDs
                                 };
    
    NSDictionary *shareProperties = @{
                                      @"og:url"         : kQMHomeUrl,
                                      @"og:image"       : kQMLogoUrl,
                                      @"og:site_name"        : kQMAppName,
                                      //@"caption"     : kQMAppName,
                                      @"og:description" : @"",
                                      //@"place"       : @"155021662189",
                                      //@"message"     : NSLocalizedString(@"QM_STR_DEAR_FRIEND", nil),
                                      //@"tags"        : usersIDs
                                 };
    
    FBSDKShareOpenGraphObject *shareObject = [FBSDKShareOpenGraphObject objectWithProperties:postParams];
    
    
//    [FBRequestConnection startWithGraphPath:@"me/feed"
//                                 parameters:postParams
//                                 HTTPMethod:@"POST"
//                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
//                              completion(error);
//                          }];
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
        completion(result);
    }];
}

+ (void)inviteFriendsWithCompletion:(void(^)(BOOL success))completion {
    
    FBSDKAppInviteContent *content =[[FBSDKAppInviteContent alloc] init];
    content.appLinkURL = [NSURL URLWithString:kQMHomeUrl];
    //optionally set previewImageURL
    content.appInvitePreviewImageURL = [NSURL URLWithString:kQMLogoUrl];
    
    // present the dialog. Assumes self implements protocol `FBSDKAppInviteDialogDelegate`
    [FBSDKAppInviteDialog showWithContent:content
                                 delegate:self];
    
//    [FBWebDialogs presentRequestsDialogModallyWithSession:nil
//                                                  message:NSLocalizedString(@"QM_STR_DEAR_FRIEND", nil)
//                                                    title:kQMAppName
//                                               parameters:nil
//                                                  handler:
//     ^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
//         
//         if (error) {
//             // Error launching the dialog or sending the request.
//             ILog(@"Error sending request.");
//             completion(NO);
//             
//         } else {
//             
//             //Indicates that the dialog operation was not completed.
//             //This occurs in cases such as the closure of the web-view
//             //using the X in the upper left corner.
//             
//             if (result == FBWebDialogResultDialogNotCompleted) {
//                 ILog(@"User canceled request.");
//                 completion(NO);
//             } else {
//                 // Handle the send request callback
//                 NSDictionary *urlParams = [self parseURLParams:[resultURL query]];
//                 if (![urlParams valueForKey:@"request"]) {
//                     // User clicked the Cancel button
//                     ILog(@"User canceled request.");
//                 } else {
//                     // User clicked the Send button
//                     __unused NSString *requestID = [urlParams valueForKey:@"request"];
//                     ILog(@"Request ID: %@", requestID);
//                     completion(YES);
//                 }
//             }
//         }
//     }];
}

+ (NSDictionary*)parseURLParams:(NSString *)query {
    
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = @{}.mutableCopy;
    
    for (NSString *pair in pairs) {
        
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val = [kv[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        params[kv[0]] = val;
    }
    
    return params;
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
         logInWithReadPermissions: @[@"public_profile", @"user_friends"]
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
        completion(session.tokenString);
    }
}

- (void)appInviteDialog:(FBSDKAppInviteDialog *)appInviteDialog didCompleteWithResults:(NSDictionary *)results {
    
}

- (void)appInviteDialog:(FBSDKAppInviteDialog *)appInviteDialog didFailWithError:(NSError *)error {
    
}

@end
