//
//  QMFacebook.m
//  Q-municate
//
//  Created by Andrey Ivanov on 27.02.15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import "QMFacebook.h"

NSString *const kQMAppHomeUrl = @"http://q-municate.com";
NSString *const kQMAppLogoUrl = @"http://files.quickblox.com/ic_launcher.png";
NSString *const kQMAppName = @"Q-municate";
NSString *const kQMFacebookGraphObjectDataKey = @"data";
NSString *const kFBGraphGetPictureFormat = @"https://graph.facebook.com/%@/picture?height=100&width=100&access_token=%@";

@implementation QMFacebook

- (void)frends:(void(^)(NSArray *frends))completion {
    
    FBRequest *friendsRequest = [FBRequest requestForGraphPath:@"me/friends"];
    
    [friendsRequest startWithCompletionHandler:^(FBRequestConnection *connection,
                                                 FBGraphObject *result,
                                                 NSError *error) {
        NSArray *friends = result[kQMFacebookGraphObjectDataKey];
        completion(friends);
    }];
}

- (void)fetchMyFriendsIDs:(void(^)(NSArray *frendsIDs))completion {
    
    [self frends:^(NSArray *friends) {
        
        NSArray *array = [friends valueForKeyPath:@"@distinctUnionOfObjects.objectID"];
        
        completion(array);
    }];
}

- (void)shareToUsers:(NSString *)usersIDs completion:(void(^)(NSError *error))completion {
    
    NSDictionary *postParams =
    @{
      @"link" : kQMAppHomeUrl,
      @"picture" : kQMAppHomeUrl,
      @"name" : kQMAppName,
      @"caption" : kQMAppName,
      @"description" : @"",
      @"place":@"155021662189",
      @"message": NSLocalizedString(@"QM_STR_DEAR_FRIEND", nil),
      @"tags" : usersIDs
      };
    
    [FBRequestConnection startWithGraphPath:@"me/feed"
                                 parameters:postParams
                                 HTTPMethod:@"POST"
                          completionHandler:^(FBRequestConnection *connection,
                                              id result,
                                              NSError *error) {
                              
                              completion(error);
                          }];
}

- (NSURL *)userImageUrlWithUserID:(NSString *)userID {
    
    FBSession *session = [FBSession activeSession];
    NSString *urlString = [NSString stringWithFormat:kFBGraphGetPictureFormat, userID, session.accessTokenData.accessToken];
    NSURL *url = [NSURL URLWithString:urlString];
    return url;
}

- (void)loadMe:(void(^)(NSDictionary<FBGraphUser> *user))completion {
    
    FBRequest *friendsRequest = [FBRequest requestForMe];
    
    [friendsRequest startWithCompletionHandler:^(FBRequestConnection *connection,
                                                 NSDictionary<FBGraphUser> *user,
                                                 NSError *error)
     {
         completion(user);
     }];
}

- (void)inviteFriendsWithCompletion:(void(^)(BOOL success))completion {
    
    [FBWebDialogs presentRequestsDialogModallyWithSession:nil
                                                  message:NSLocalizedString(@"QM_STR_DEAR_FRIEND", nil)
                                                    title:kQMAppName
                                               parameters:nil
                                                  handler:^(FBWebDialogResult
                                                            result,
                                                            NSURL *resultURL,
                                                            NSError *error)
     {
         
         if (error) {
             // Error launching the dialog or sending the request.
             ILog(@"Error sending request.");
             completion(NO);
             
         }
         else {
             //Indicates that the dialog operation was not completed.
             //This occurs in cases such as the closure of the web-view
             //using the X in the upper left corner.
             
             if (result == FBWebDialogResultDialogNotCompleted) {
                 
                 ILog(@"User canceled request.");
                 completion(NO);
             }
             else {
                 // Handle the send request callback
                 NSDictionary *urlParams = [self parseURLParams:[resultURL query]];
                 if (!urlParams[@"request"]) {
                     // User clicked the Cancel button
                     ILog(@"User canceled request.");
                 }
                 else {
                     // User clicked the Send button
                     __unused NSString *requestID = urlParams[@"request"];
                     ILog(@"Request ID: %@", requestID);
                     completion(YES);
                 }
             }
         }
     }];
}

- (NSDictionary *)parseURLParams:(NSString *)query {
    
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = @{}.mutableCopy;
    
    for (NSString *pair in pairs) {
        
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val = [kv[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        params[kv[0]] = val;
    }
    
    return params;
}

- (void)logout {
    
    // If the session state is any of the two "open"
    if (FBSession.activeSession.state == FBSessionStateOpen ||
        FBSession.activeSession.state == FBSessionStateOpenTokenExtended) {
        // Close the session and remove the access token from the cache
        // The session state handler (in the app delegate) will be called automatically
        [FBSession.activeSession closeAndClearTokenInformation];
        // If the session state is not any of the two "open" states when the button is clicked
    }
    
    NSHTTPCookieStorage* cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray* facebookCookies = [cookies cookiesForURL:[NSURL URLWithString:@"https://facebook.com/"]];
    
    for (NSHTTPCookie* cookie in facebookCookies) {
        [cookies deleteCookie:cookie];
    }
    
    FBSession.activeSession = nil;
}

- (void)openSession:(void(^)(NSString *sessionToken))completion {
    
    
    if (!FBSession.activeSession.isOpen) {
        
        FBSessionState fbState = FBSession.activeSession.state;
        
        if (fbState == FBSessionStateClosed ||
            fbState == FBSessionStateClosedLoginFailed) {
            
            FBSession *newSession = [[FBSession alloc] initWithPermissions:@[@"public_profile", @"user_friends"]];
            [FBSession setActiveSession:newSession];
        }
        
        __weak __typeof(self)weakSelf = self;
        
        [FBSession.activeSession openWithCompletionHandler:^(FBSession *session,
                                                             FBSessionState status,
                                                             NSError *error) {
            
            if (status == FBSessionStateClosed && error == nil) {
                return;
            }
            
            if (error) {
                
                weakSelf.lastErrorMessage = [FBErrorUtility userMessageForError:error];
                
                if (status == FBSessionStateClosedLoginFailed) {
                    
                    [FBSession.activeSession closeAndClearTokenInformation];
                }
                completion(nil);
            }
            
            completion(session.accessTokenData.accessToken);
        }];
        
    }
    else {
        
        completion(FBSession.activeSession.accessTokenData.accessToken);
    }
}

@end
