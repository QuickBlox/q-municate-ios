//
//  AppDelegate.m
//  Q-municate
//
//  Created by Igor Alefirenko on 13/02/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "AppDelegate.h"
#import "QMIncomingCallHandler.h"

const NSUInteger kQMApplicationID = 7232;
NSString *const kQMAuthorizationKey = @"MpOecRZy-5WsFva";
NSString *const kQMAuthorizationSecret = @"dTSLaxDsFKqegD7";
NSString *const kQMAcconuntKey = @"LpNmxA2Pq2uyW5qBjHy8";

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];

    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];

    [QBSettings setApplicationID:kQMApplicationID];
    [QBSettings setAuthorizationKey:kQMAuthorizationKey];
    [QBSettings setAuthorizationSecret:kQMAuthorizationSecret];
    [QBSettings setAccountKey:kQMAcconuntKey];
    [QBSettings setLogLevel:QBLogLevelDebug];
    
    /*Configure app appearance*/
    NSDictionary *normalAttributes = @{NSForegroundColorAttributeName : [UIColor colorWithWhite:1.000 alpha:0.830]};
    NSDictionary *disabledAttributes = @{NSForegroundColorAttributeName : [UIColor colorWithWhite:0.935 alpha:0.260]};
    [[UIBarButtonItem appearance] setTitleTextAttributes:normalAttributes forState:UIControlStateNormal];
    [[UIBarButtonItem appearance] setTitleTextAttributes:disabledAttributes forState:UIControlStateDisabled];
    return YES;
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSLog(@"Push war received. User info: %@", userInfo);
}

- (void)applicationWillResignActive:(UIApplication *)application {}

- (void)applicationDidEnterBackground:(UIApplication *)application {}

- (void)applicationWillEnterForeground:(UIApplication *)application {}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
    [FBSession.activeSession handleDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application {}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {

    BOOL urlWasIntendedForFacebook = [FBSession.activeSession handleOpenURL:url];
    return urlWasIntendedForFacebook;
}

@end
