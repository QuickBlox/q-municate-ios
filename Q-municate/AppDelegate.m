//
//  AppDelegate.m
//  Q-municate
//
//  Created by Igor Alefirenko on 13/02/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "AppDelegate.h"
#import "QMincomingCallService.h"

const NSUInteger kQMApplicationID = 7232;
NSString *const kQMAuthorizationKey = @"MpOecRZy-5WsFva";
NSString *const kQMAuthorizationSecret = @"dTSLaxDsFKqegD7";
NSString *const kQMAcconuntKey = @"LpNmxA2Pq2uyW5qBjHy8";

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [QMDBStorage setupWithName:@"Andrey"];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    /**
     Setup framework
     Quickblox credentials
     */
    [QBSettings setApplicationID:7232];
    [QBSettings setAuthorizationKey:@"MpOecRZy-5WsFva"];
    [QBSettings setAuthorizationSecret:@"dTSLaxDsFKqegD7"];
    [QBSettings setAccountKey:@"LpNmxA2Pq2uyW5qBjHy8"];
//    [QBSettings setLogLevel:QBLogLevelNothing];
     self.incomingCallService = [[QMIncomingCallService alloc] init];
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
