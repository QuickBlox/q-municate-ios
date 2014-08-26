//
//  QMFacebookService.m
//  Q-municate
//
//  Created by Igor Alefirenko on 26/03/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMFacebookService.h"
#import "REAlertView+QMSuccess.h"

@implementation QMFacebookService

NSString *const kQMHomeUrl = @"http://q-municate.com";
NSString *const kQMLogoUrl = @"http://files.quickblox.com/ic_launcher.png";
NSString *const kQMAppName = @"Q-municate";
NSString *const kQMDataKey = @"data";

+ (void)fetchMyFriends:(void(^)(NSArray *facebookFriends))completion {
    
    FBRequest *friendsRequest = [FBRequest requestForGraphPath:@"me/friends"];
    [friendsRequest startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        NSArray *myFriends = error ? @[] : [(FBGraphObject *)result objectForKey:kQMDataKey];
        completion(myFriends);
    }];
}

+ (void)fetchMyFriendsIDs:(void(^)(NSArray *facebookFriendsIDs))completion {
    
    [self fetchMyFriends:^(NSArray *facebookFriends) {
        
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:facebookFriends.count];
        for (NSDictionary<FBGraphUser> *user in facebookFriends) {
            [array addObject:user.id];
        }
        completion(array);
    }];
}

+ (void)shareToUsers:(NSString *)usersIDs completion:(void(^)(NSError *error))completion {
    
    NSDictionary *postParams = @{
                                 @"link" : kQMHomeUrl,
                                 @"picture" : kQMLogoUrl,
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
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                              completion(error);
                          }];
}

NSString *const kFBGraphGetPictureFormat = @"https://graph.facebook.com/%@/picture?height=100&width=100&access_token=%@";

+ (NSURL *)userImageUrlWithUserID:(NSString *)userID {
    
    FBSession *session = [FBSession activeSession];
    NSString *urlString = [NSString stringWithFormat:kFBGraphGetPictureFormat, userID, session.accessTokenData.accessToken];
    NSURL *url = [NSURL URLWithString:urlString];
    return url;
}

+ (void)loadMe:(void(^)(NSDictionary<FBGraphUser> *user))completion {
    
    FBRequest *friendsRequest = [FBRequest requestForMe];
    
    [friendsRequest startWithCompletionHandler:^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *user, NSError *error) {
        completion(user);
    }];
}

+ (void)inviteFriendsWithCompletion:(void(^)(BOOL success))completion {
    
    [FBWebDialogs presentRequestsDialogModallyWithSession:nil
                                                  message:NSLocalizedString(@"QM_STR_DEAR_FRIEND", nil)
                                                    title:kQMAppName
                                               parameters:nil
                                                  handler:
     ^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
         
         if (error) {
             // Error launching the dialog or sending the request.
             ILog(@"Error sending request.");
             completion(NO);
             
         } else {
             
             //Indicates that the dialog operation was not completed.
             //This occurs in cases such as the closure of the web-view
             //using the X in the upper left corner.
             
             if (result == FBWebDialogResultDialogNotCompleted) {
                 ILog(@"User canceled request.");
                 completion(NO);
             } else {
                 // Handle the send request callback
                 NSDictionary *urlParams = [self parseURLParams:[resultURL query]];
                 if (![urlParams valueForKey:@"request"]) {
                     // User clicked the Cancel button
                     ILog(@"User canceled request.");
                 } else {
                     // User clicked the Send button
                     __unused NSString *requestID = [urlParams valueForKey:@"request"];
                     ILog(@"Request ID: %@", requestID);
                     completion(YES);
                 }
             }
         }
     }];
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
    
    // If the session state is any of the two "open"
    if (FBSession.activeSession.state == FBSessionStateOpen || FBSession.activeSession.state == FBSessionStateOpenTokenExtended) {
        // Close the session and remove the access token from the cache
        // The session state handler (in the app delegate) will be called automatically
        [FBSession.activeSession closeAndClearTokenInformation];
        // If the session state is not any of the two "open" states when the button is clicked
    }
    FBSession.activeSession = nil;
}
//
//+ (BOOL)isSessionStateEffectivelyLoggedIn:(FBSessionState)state {
//    BOOL effectivelyLoggedIn;
//
//    switch (state) {
//        case FBSessionStateOpen:
//            ILog(@"Facebook session state: FBSessionStateOpen");
//            effectivelyLoggedIn = YES;
//            break;
//        case FBSessionStateCreatedTokenLoaded:
//            ILog(@"Facebook session state: FBSessionStateCreatedTokenLoaded");
//            effectivelyLoggedIn = YES;
//            break;
//        case FBSessionStateOpenTokenExtended:
//            ILog(@"Facebook session state: FBSessionStateOpenTokenExtended");
//            effectivelyLoggedIn = YES;
//            break;
//        default:
//            ILog(@"Facebook session state: not of one of the open or openable types.");
//            effectivelyLoggedIn = NO;
//            break;
//    }
//
//    return effectivelyLoggedIn;
//}

/**
 * Determines if the Facebook session has an authorized state. It might still need to be opened if it is a cached
 * token, but the purpose of this call is to determine if the user is authorized at least that they will not be
 * explicitly asked anything.
 */

//+ (BOOL)isLoggedIn {
//
//    FBSession *activeSession = [FBSession activeSession];
//    FBSessionState state = activeSession.state;
//    BOOL isLoggedIn = activeSession && [self isSessionStateEffectivelyLoggedIn:state];
//
//    ILog(@"Facebook active session state: %d; logged in conclusion: %@", state, isLoggedIn ? @"YES" : @"NO");
//
//    return isLoggedIn;
//}

/**
 * Attempts to silently open the Facebook session if we have a valid token loaded (that perhaps needs a behind the scenes refresh).
 * After that attempt, we defer to the basic concept of the session being in one of the valid authorized states.
 */

+ (void)connectToFacebook:(void(^)(NSString *sessionToken))completion {
    
    __weak __typeof(self)weakSelf = self;
    
    // Whenever a person opens the app, check for a cached session
    if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
        ILog(@"We have a cached token, so we're going to re-establish the login for the user.");
        // If there's one, just open the session silently, without showing the user the login UI
        
    } else {
        // If there's no cached session, we will show a login button
        // Open a session showing the user the login UI
        // You must ALWAYS ask for public_profile permissions when opening a session
        ILog(@"Active session wasn't in state 'FBSessionStateCreatedTokenLoaded'. It has state: %d", FBSession.activeSession.state);
    }
    
    if (!FBSession.activeSession.isOpen) {
        
        [FBSession.activeSession openWithCompletionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
            if (status == FBSessionStateClosed && error == nil) {
                return;
            }
            
            [weakSelf sessionStateChanged:session state:status error:error sessionBlock:completion];
        }];
    } else {
        completion(FBSession.activeSession.accessTokenData.accessToken);
    }
}

// This method will handle ALL the session state changes in the app
+ (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState)state
                      error:(NSError *)error
               sessionBlock:(void(^)(NSString *sessionToken))sessionBlock  {
    
    // If the session was opened successfully
    if (error) {
        
        NSString *alertText;
        
        FBErrorCategory errorCategory = [FBErrorUtility errorCategoryForError:error];
        
        BOOL shouldNotify = [FBErrorUtility shouldNotifyUserForError:error];
        
        if (shouldNotify) {
            
            alertText = [FBErrorUtility userMessageForError:error];
            
        } else {
            shouldNotify = YES;
            // If the user cancelled login, do nothing
            if (errorCategory == FBErrorCategoryUserCancelled) {
                shouldNotify = NO;
                // Handle session closures that happen outside of the app
            } else if (errorCategory == FBErrorCategoryAuthenticationReopenSession) {
                
                alertText = NSLocalizedString(@"QM_STR_YOUR _SURRENT_SESSION_IS_NO_LONGER_VALID", nil);
                
                // For simplicity, here we just show a generic message for all other errors
                // You can learn how to handle other errors using our guide: https://developers.facebook.com/docs/ios/errors
            } else {
                
                if (error) {
                    //Get more error information from the error
                    NSDictionary *errorInformation =
                    [[[error.userInfo objectForKey:@"com.facebook.sdk:ParsedJSONResponseKey"] objectForKey:@"body"] objectForKey:@"error"];
                    
                    // Show the user an error message
                    alertText = [NSString stringWithFormat:@"Please retry. \n\n If the problem persists contact us and mention this error code: %@",
                                 [errorInformation objectForKey:@"message"]];
                } else {
                    shouldNotify = NO;
                }
            }
        }
        
        if (shouldNotify) [REAlertView showAlertWithMessage:alertText actionSuccess:NO];
    }
    sessionBlock(session.accessTokenData.accessToken);
}

@end
