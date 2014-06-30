//
//  QMFacebookService.m
//  Q-municate
//
//  Created by Igor Alefirenko on 26/03/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMFacebookService.h"
#import "QMContactList.h"
#import "REAlertView.h"

@interface QMFacebookService ()

@end

@implementation QMFacebookService

NSString *const kQMQuickbloxHomeUrl = @"http://quickblox.com";
NSString *const kQMQuickbloxLogoUrl = @"https://qbprod.s3.amazonaws.com/c6e81081d5954ed68485eead941b91a000";
NSString *const kQMAppName = @"Q-municate";

- (void)shareToFacebookUsersWithIDs:(NSString *)facebookIDs withCompletion:(FBCompletionBlock)handler {
    
    NSDictionary *postParams = @{
                                 @"link" : kQMQuickbloxHomeUrl,
                                 @"picture" : kQMQuickbloxLogoUrl,
                                 @"name" : kQMAppName,
                                 @"caption" : @"By QuickBlox",
                                 @"description" : @"Join to new world of audio & video calls",
                                 @"place":@"155021662189",
                                 @"message": @"Very Nice!",
                                 @"tags" : facebookIDs
                                 };
    
    [FBRequestConnection startWithGraphPath:@"me/feed"
                                 parameters:postParams
                                 HTTPMethod:@"POST"
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                              handler((BOOL)result, error);
                          }];
}

NSString *const kFBGraphGetPictureFormat = @"https://graph.facebook.com/%@/picture?height=100&width=100&access_token=%@";

- (void)loadUserImageFromFacebookWithUserID:(NSString *)userID completion:(ImageBlock)handler {
    
    FBSession *session = [FBSession activeSession];
    NSString *urlString = [NSString stringWithFormat:kFBGraphGetPictureFormat, userID, session.accessTokenData.accessToken];
    NSURL *url = [NSURL URLWithString:urlString];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
        dispatch_async(dispatch_get_main_queue(), ^{
            handler(image);
        });
    });
}

- (void)loadMeWithCompletion:(FBContentBlock)handler {
    
    FBRequest *friendsRequest = [FBRequest requestForMe];
    
    [friendsRequest startWithCompletionHandler:^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *user, NSError *error) {
        handler(user, error);
    }];
    
}

- (void)fetchFacebookFriendsUsingBlock:(QBChatResultBlock)block {
    
    FBRequest *friendsRequest = [FBRequest requestForMyFriends];
    [friendsRequest startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        
        NSMutableArray *myFriends = [(FBGraphObject *)result objectForKey:kData];
        [QMContactList shared].facebookFriendsToInvite = myFriends;
        
        block(YES);
    }];
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
        [self logout];
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
        // Clear this token
        [FBSession.activeSession closeAndClearTokenInformation];
        // Show the user the logged-out UI
        [self logout];
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
