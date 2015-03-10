//
//  AppDelegate.m
//  Q-municate
//
//  Created by Igor Alefirenko on 13/02/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "AppDelegate.h"
#import <Crashlytics/Crashlytics.h>
#import "SVProgressHUD.h"

#if Q_MUNICATE_MODE == 0
/**
 *  Development Quickblox settings
 */
const NSUInteger kQMApplicationID = 14542;
NSString *const kQMAuthorizationKey = @"rJqAFphrSnpyZW2";
NSString *const kQMAuthorizationSecret = @"tTEB2wK-dU8X3Ra";
NSString *const kQMAcconuntKey = @"2qCrjKYFkYnfRnUiYxLZ";
#elif Q_MUNICATE_MODE == 1
/**
 *  Production Quickblox settings
 */
const NSUInteger kQMApplicationID = 13318;
NSString *const kQMAuthorizationKey = @"WzrAY7vrGmbgFfP";
NSString *const kQMAuthorizationSecret = @"xS2uerEveGHmEun";
NSString *const kQMAcconuntKey = @"6Qyiz3pZfNsex1Enqnp7";
#endif
/**
 *  Crashlytics API key
 */
NSString *const kQMCrashlyticsAPIKey = @"7aea78439bec41a9005c7488bb6751c5e33fe270";

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    UIApplication.sharedApplication.statusBarStyle = UIStatusBarStyleDefault;
    UIApplication.sharedApplication.applicationIconBadgeNumber = 0;
    
    QBApplication.sharedApplication.applicationId = kQMApplicationID;
    [QBConnection registerServiceKey:kQMAuthorizationKey];
    [QBConnection registerServiceSecret:kQMAuthorizationSecret];
    
    [QBSettings setAccountKey:kQMAcconuntKey];
    [QBSettings setLogLevel:QBLogLevelDebug];
    
#ifndef DEBUG
    [QBSettings useProductionEnvironmentForPushNotifications:YES];
#endif
    
#if STAGE_SERVER_IS_ACTIVE == 1
    [QBSettings setServerApiDomain:@"http://api.stage.quickblox.com"];
    [QBSettings setServerChatDomain:@"chatstage.quickblox.com"];
#endif
    /**Start Crashlytics */
    [Crashlytics startWithAPIKey:kQMCrashlyticsAPIKey];
    
    return YES;
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    ILog(@"Push war received. User info:%@", userInfo);
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
    
    BOOL urlWasHandled =
    [FBAppCall handleOpenURL:url
           sourceApplication:sourceApplication
             fallbackHandler:^(FBAppCall *call) {
                 NSLog(@"Unhandled deep link: %@", url);
             }];
    
    return urlWasHandled;
}

@end
