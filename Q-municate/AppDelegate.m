//
//  AppDelegate.m
//  Q-municate
//
//  Created by Igor Alefirenko on 13/02/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "AppDelegate.h"
#import "QMIncomingCallHandler.h"
#import "SVProgressHUD.h"
#import "QMApi.h"

const NSUInteger kQMApplicationID = 7232;
NSString *const kQMAuthorizationKey = @"MpOecRZy-5WsFva";
NSString *const kQMAuthorizationSecret = @"dTSLaxDsFKqegD7";
NSString *const kQMAcconuntKey = @"LpNmxA2Pq2uyW5qBjHy8";

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
//    self.incomingCallService = [[QMIncomingCallHandler alloc] init];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];

    [QBSettings setApplicationID:kQMApplicationID];
    [QBSettings setAuthorizationKey:kQMAuthorizationKey];
    [QBSettings setAuthorizationSecret:kQMAuthorizationSecret];
    [QBSettings setAccountKey:kQMAcconuntKey];
    [QBSettings setLogLevel:QBLogLevelDebug];
    
    /*Configure app appearance*/
    NSDictionary *normalAttributes = @{NSForegroundColorAttributeName : [UIColor colorWithWhite:1.000 alpha:0.750]};
    NSDictionary *disabledAttributes = @{NSForegroundColorAttributeName : [UIColor colorWithWhite:0.935 alpha:0.260]};
    [[UIBarButtonItem appearance] setTitleTextAttributes:normalAttributes forState:UIControlStateNormal];
    [[UIBarButtonItem appearance] setTitleTextAttributes:disabledAttributes forState:UIControlStateDisabled];
    
    [[UIBarButtonItem appearanceWhenContainedIn:[UIImagePickerController class], nil] setTitleTextAttributes:nil forState:UIControlStateNormal];
    [[UIBarButtonItem appearanceWhenContainedIn:[UIImagePickerController class], nil] setTitleTextAttributes:nil forState:UIControlStateDisabled];
    
    [[SVProgressHUD appearance] setHudBackgroundColor:[UIColor colorWithRed:0.046 green:0.377 blue:0.633 alpha:1.000]];
    [[SVProgressHUD appearance] setHudForegroundColor:[UIColor colorWithWhite:1.000 alpha:1.000]];
    
    return YES;
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSLog(@"Push war received. User info: %@", userInfo);
}

- (void)applicationDidEnterBackground:(UIApplication *)application {}

- (void)applicationWillEnterForeground:(UIApplication *)application {}

- (void)applicationWillResignActive:(UIApplication *)application {
    [[QMApi instance] applicationWillResignActive];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [[QMApi instance] applicationDidBecomeActive];
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
