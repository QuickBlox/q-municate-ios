//
//  QMFacebookService.m
//  Q-municate
//
//  Created by Igor Alefirenko on 26/03/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMFacebookService.h"
#import "REAlertView.h"

@interface QMFacebookService ()

@end

@implementation QMFacebookService

NSString *const kQMQuickbloxHomeUrl = @"http://quickblox.com";
NSString *const kQMQuickbloxLogoUrl = @"https://qbprod.s3.amazonaws.com/c6e81081d5954ed68485eead941b91a000";
NSString *const kQMAppName = @"Q-municate";

- (void)fetchMyFriends:(void(^)(NSArray *facebookFriends))completion {
    
    FBRequest *friendsRequest = [FBRequest requestForMyFriends];
    [friendsRequest startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        NSArray *myFriends = error ? @[] : [(FBGraphObject *)result objectForKey:kData];
        completion(myFriends);
    }];
}

- (void)fetchMyFriendsIDs:(void(^)(NSArray *facebookFriendsIDs))completion {
    
    [self fetchMyFriends:^(NSArray *facebookFriends) {
        
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:facebookFriends.count];
        for (NSDictionary<FBGraphUser> *user in facebookFriends) {
            [array addObject:user.id];
        }
        completion(array);
    }];
}


- (void)shareToUsers:(NSString *)usersIDs completion:(void(^)(NSError *error))completion {
    
    NSDictionary *postParams = @{
                                 @"link" : kQMQuickbloxHomeUrl,
                                 @"picture" : kQMQuickbloxLogoUrl,
                                 @"name" : kQMAppName,
                                 @"caption" : @"By QuickBlox",
                                 @"description" : @"Join to new world of audio & video calls",
                                 @"place":@"155021662189",
                                 @"message": @"Very Nice!",
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

- (NSURL *)userImageUrlWithUserID:(NSString *)userID {

    FBSession *session = [FBSession activeSession];
    NSString *urlString = [NSString stringWithFormat:kFBGraphGetPictureFormat, userID, session.accessTokenData.accessToken];
    NSURL *url = [NSURL URLWithString:urlString];
    return url;
}

- (void)loadUserImageWithUserID:(NSString *)userID completion:(void(^)(UIImage *fbUserImage))completion {
    
    NSURL *url = [self userImageUrlWithUserID:userID];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(image);
        });
    });
}

- (void)loadMe:(void(^)(NSDictionary<FBGraphUser> *user))completion {
    
    FBRequest *friendsRequest = [FBRequest requestForMe];
    
    [friendsRequest startWithCompletionHandler:^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *user, NSError *error) {
        completion(user);
    }];
}

- (void)inviteFriends {
    
    [FBWebDialogs presentRequestsDialogModallyWithSession:nil message:@"Q-municate." title:nil parameters:nil handler:
     
     ^(FBWebDialogResult result, NSURL *resultURL, NSError *error)
     {
         if (error) {
             // Error launching the dialog or sending the request.
             NSLog(@"Error sending request.");
         } else {
             if (result == FBWebDialogResultDialogNotCompleted) {
                 // User clicked the "x" icon
                 NSLog(@"User canceled request.");
             } else {
                 // Handle the send request callback
                 NSDictionary *urlParams = [self parseURLParams:[resultURL query]];
                 if (![urlParams valueForKey:@"request"]) {
                     // User clicked the Cancel button
                     NSLog(@"User canceled request.");
                 } else {
                     // User clicked the Send button
                     NSString *requestID = [urlParams valueForKey:@"request"];
                     NSLog(@"Request ID: %@", requestID);
                 }
             }
         }
     }];
}

- (NSDictionary*)parseURLParams:(NSString *)query {
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val =
        [kv[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        params[kv[0]] = val;
    }
    return params;
}

- (void)logout {
    
    // If the session state is any of the two "open"
    if (FBSession.activeSession.state == FBSessionStateOpen
        || FBSession.activeSession.state == FBSessionStateOpenTokenExtended) {
        // Close the session and remove the access token from the cache
        // The session state handler (in the app delegate) will be called automatically
        [FBSession.activeSession closeAndClearTokenInformation];
        // If the session state is not any of the two "open" states when the button is clicked
    }
}

- (void)connectToFacebook:(void(^)(NSString *sessionToken))completion {
    // Whenever a person opens the app, check for a cached session
    if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
        NSLog(@"Found a cached session");
        // If there's one, just open the session silently, without showing the user the login UI
        [FBSession openActiveSessionWithReadPermissions:@[@"public_profile"]
                                           allowLoginUI:NO
                                      completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                                          // Handler for session state changes
                                          [self sessionStateChanged:session state:state error:error completion:completion];
                                      }];
        
        // If there's no cached session, we will show a login button
    } else {
        // Open a session showing the user the login UI
        // You must ALWAYS ask for public_profile permissions when opening a session
        [FBSession openActiveSessionWithReadPermissions:@[@"public_profile"]
                                           allowLoginUI:YES
                                      completionHandler:
         ^(FBSession *session, FBSessionState state, NSError *error) {
             
             // Call  sessionStateChanged:state:error method to handle session state changes
             [self sessionStateChanged:session state:state error:error completion:completion];
         }];
    }
}

// This method will handle ALL the session state changes in the app
- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error completion:(void(^)(NSString *sessionToken))completion  {
    // If the session was opened successfully
    if (!error && state == FBSessionStateOpen){
        NSLog(@"Session opened");
        // Show the user the logged-in UI
        completion(session.accessTokenData.accessToken);
        return;
    }
    
    if (state == FBSessionStateClosed || state == FBSessionStateClosedLoginFailed){
        // If the session is closed
        NSLog(@"Session closed");
        // Show the user the logged-out UI
    }
    
    // Handle errors
    if (error){
        
        NSLog(@"Error");
        NSString *alertText;
        NSString *alertTitle;
        // If the error requires people using an app to make an action outside of the app in order to recover
        if ([FBErrorUtility shouldNotifyUserForError:error] == YES){
            alertTitle = @"Something went wrong";
            alertText = [FBErrorUtility userMessageForError:error];
            [self showMessage:alertText withTitle:alertTitle];
        } else {
            
            // If the user cancelled login, do nothing
            if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
                NSLog(@"User cancelled login");
                
                // Handle session closures that happen outside of the app
            } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession){
                alertTitle = @"Session Error";
                alertText = @"Your current session is no longer valid. Please log in again.";
                [self showMessage:alertText withTitle:alertTitle];
                
                // For simplicity, here we just show a generic message for all other errors
                // You can learn how to handle other errors using our guide: https://developers.facebook.com/docs/ios/errors
            } else {
                //Get more error information from the error
                NSDictionary *errorInformation = [[[error.userInfo objectForKey:@"com.facebook.sdk:ParsedJSONResponseKey"] objectForKey:@"body"] objectForKey:@"error"];
                
                // Show the user an error message
                alertTitle = @"Something went wrong";
                alertText = [NSString stringWithFormat:@"Please retry. \n\n If the problem persists contact us and mention this error code: %@", [errorInformation objectForKey:@"message"]];
                [self showMessage:alertText withTitle:alertTitle];
            }
        }
        completion(nil);
    }
}

- (void)showMessage:(NSString *)message withTitle:(NSString *)title {
    
    [REAlertView presentAlertViewWithConfiguration:^(REAlertView *alertView) {
        alertView.title = title;
        alertView.message = message;
        [alertView addButtonWithTitle:kAlertButtonTitleOkString andActionBlock:^{}];
    }];
}

@end
