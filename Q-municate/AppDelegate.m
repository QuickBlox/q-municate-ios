//
//  AppDelegate.m
//  Q-municate
//
//  Created by Igor Alefirenko on 13/02/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "AppDelegate.h"
#import <Crashlytics/Crashlytics.h>
#import "QMIncomingCallHandler.h"
#import "SVProgressHUD.h"
#import "QMApi.h"


#define DEVELOPMENT 0

#if DEVELOPMENT

// Development
const NSUInteger kQMApplicationID = 14542;
NSString *const kQMAuthorizationKey = @"rJqAFphrSnpyZW2";
NSString *const kQMAuthorizationSecret = @"tTEB2wK-dU8X3Ra";
NSString *const kQMAcconuntKey = @"2qCrjKYFkYnfRnUiYxLZ";

#else

// Production
const NSUInteger kQMApplicationID = 13318;
NSString *const kQMAuthorizationKey = @"WzrAY7vrGmbgFfP";
NSString *const kQMAuthorizationSecret = @"xS2uerEveGHmEun";
NSString *const kQMAcconuntKey = @"6Qyiz3pZfNsex1Enqnp7";

#endif

/* ==================================================================== */

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    UIApplication.sharedApplication.statusBarStyle = UIStatusBarStyleDefault;
#if QM_AUDIO_VIDEO_ENABLED == 1
    self.incomingCallService = [[QMIncomingCallHandler alloc] init];
#endif
    self.window.backgroundColor = [UIColor whiteColor];
    
    UIApplication.sharedApplication.applicationIconBadgeNumber = 0;
    
    [QBSettings setApplicationID:kQMApplicationID];
    [QBSettings setAuthorizationKey:kQMAuthorizationKey];
    [QBSettings setAuthorizationSecret:kQMAuthorizationSecret];
    [QBSettings setAccountKey:kQMAcconuntKey];
    [QBSettings setLogLevel:QBLogLevelDebug];
    
    
#ifndef DEBUG
    [QBSettings useProductionEnvironmentForPushNotifications:YES];
#endif
    
    
#if STAGE_SERVER_IS_ACTIVE == 1
    [QBSettings setServerApiDomain:@"http://api.stage.quickblox.com"];
    [QBSettings setServerChatDomain:@"chatstage.quickblox.com"];
#endif
    
    /*Configure app appearance*/
    NSDictionary *normalAttributes = @{NSForegroundColorAttributeName : [UIColor colorWithWhite:1.000 alpha:0.750]};
    NSDictionary *disabledAttributes = @{NSForegroundColorAttributeName : [UIColor colorWithWhite:0.935 alpha:0.260]};
    
    [[UIBarButtonItem appearance] setTitleTextAttributes:normalAttributes forState:UIControlStateNormal];
    [[UIBarButtonItem appearance] setTitleTextAttributes:disabledAttributes forState:UIControlStateDisabled];
    
    [[UIBarButtonItem appearanceWhenContainedIn:[UIImagePickerController class], nil] setTitleTextAttributes:nil forState:UIControlStateNormal];
    [[UIBarButtonItem appearanceWhenContainedIn:[UIImagePickerController class], nil] setTitleTextAttributes:nil forState:UIControlStateDisabled];
    
    [[SVProgressHUD appearance] setHudBackgroundColor:[UIColor colorWithRed:0.046 green:0.377 blue:0.633 alpha:1.000]];
    [[SVProgressHUD appearance] setHudForegroundColor:[UIColor colorWithWhite:1.000 alpha:1.000]];
    
    /** Crashlytics */
    [Crashlytics startWithAPIKey:@"7aea78439bec41a9005c7488bb6751c5e33fe270"];
    
    return YES;
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    NSString *dialogID = userInfo[@"dialog_id"];
    
    
    ILog(@"Push war received. User info: %@", userInfo);
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [[QMApi instance] applicationWillResignActive];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [[QMApi instance] applicationDidBecomeActive:^(BOOL success) {
        [SVProgressHUD dismiss];
    }];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
    [FBSession.activeSession handleDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application {

}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {

    BOOL urlWasIntendedForFacebook = [FBSession.activeSession handleOpenURL:url];
    return urlWasIntendedForFacebook;
}

@end
