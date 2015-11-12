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
#import "REAlertView+QMSuccess.h"
#import "QMApi.h"
#import "QMSettingsManager.h"
#import "QMAVCallManager.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "QMViewControllersFactory.h"

#define DEVELOPMENT 0
#define STAGE_SERVER_IS_ACTIVE 0


#if DEVELOPMENT

// Development
const NSUInteger kQMApplicationID = 14542;
NSString *const kQMAuthorizationKey = @"rJqAFphrSnpyZW2";
NSString *const kQMAuthorizationSecret = @"tTEB2wK-dU8X3Ra";
NSString *const kQMAcconuntKey = @"2qCrjKYFkYnfRnUiYxLZ";



//// Stage server for E-bay:
//
//const NSUInteger kQMApplicationID = 13029;
//NSString *const kQMAuthorizationKey = @"3mBwAnczNvh-sBK";
//NSString *const kQMAuthorizationSecret = @"xWP2jgUsQOpxj-6";
//NSString *const kQMAcconuntKey = @"tLapBNZPeqCHxEA8zApx";
//NSString *const kQMContentBucket = @"blobs-test-oz";

#else

// Production
const NSUInteger kQMApplicationID = 13318;
NSString *const kQMAuthorizationKey = @"WzrAY7vrGmbgFfP";
NSString *const kQMAuthorizationSecret = @"xS2uerEveGHmEun";
NSString *const kQMAcconuntKey = @"6Qyiz3pZfNsex1Enqnp7";

#endif


/* ==================================================================== */

@interface AppDelegate () <QMNotificationHandlerDelegate>

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    UIApplication.sharedApplication.applicationIconBadgeNumber = 0;
    
    UIApplication.sharedApplication.statusBarStyle = UIStatusBarStyleDefault;
    
    self.window.backgroundColor = [UIColor whiteColor];
    
    // QB Settings
    [QBApplication sharedApplication].applicationId = kQMApplicationID;
    [QBConnection registerServiceKey:kQMAuthorizationKey];
    [QBConnection registerServiceSecret:kQMAuthorizationSecret];

    [QBSettings setAccountKey:kQMAcconuntKey];
    [QBSettings setLogLevel:QBLogLevelNothing];
    
    //QuickbloxWebRTC preferences
    [QBRTCClient initializeRTC];
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else{
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound];
    }
#else
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound];
#endif
    
#ifndef DEBUG
    [QBApplication sharedApplication].productionEnvironmentForPushesEnabled = YES;
#endif
    
    
#if STAGE_SERVER_IS_ACTIVE == 1
//    [QBSettings setServerApiDomain:@"https://api.stage.quickblox.com"];
    [QBConnection setApiDomain:@"https://api.stage.quickblox.com" forServiceZone:QBConnectionZoneTypeDevelopment];
    [QBConnection setServiceZone:QBConnectionZoneTypeDevelopment];
    [QBSettings setServerChatDomain:@"chatstage.quickblox.com"];
    [QBSettings setContentBucket: kQMContentBucket];
#endif
    
    /*Configure app appearance*/
    NSDictionary *normalAttributes = @{NSForegroundColorAttributeName : [UIColor colorWithWhite:1.000 alpha:0.750]};
    NSDictionary *disabledAttributes = @{NSForegroundColorAttributeName : [UIColor colorWithWhite:0.935 alpha:0.260]};
    
    [[UIBarButtonItem appearance] setTitleTextAttributes:normalAttributes forState:UIControlStateNormal];
    [[UIBarButtonItem appearance] setTitleTextAttributes:disabledAttributes forState:UIControlStateDisabled];
    
    [[UIBarButtonItem appearanceWhenContainedIn:[UIImagePickerController class], nil] setTitleTextAttributes:nil forState:UIControlStateNormal];
    [[UIBarButtonItem appearanceWhenContainedIn:[UIImagePickerController class], nil] setTitleTextAttributes:nil forState:UIControlStateDisabled];
    
    /** Crashlytics */
    [Crashlytics startWithAPIKey:@"7aea78439bec41a9005c7488bb6751c5e33fe270"];
    
    if (launchOptions != nil) {
        NSDictionary *notification = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
        [[QMApi instance] setPushNotification:notification];
    }

    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                    didFinishLaunchingWithOptions:launchOptions];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    if ([application applicationState] == UIApplicationStateInactive) {
        NSString *dialogID = userInfo[kPushNotificationDialogIDKey];
        if (dialogID != nil) {
            NSString *dialogWithIDWasEntered = [QMApi instance].settingsManager.dialogWithIDisActive;
            if ([dialogWithIDWasEntered isEqualToString:dialogID]) return;
            
            [[QMApi instance] setPushNotification:userInfo];
            [[QMApi instance] handlePushNotificationWithDelegate:self];
        }
        ILog(@"Push was received. User info: %@", userInfo);
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    UIApplication.sharedApplication.applicationIconBadgeNumber = 0;
    [[QMApi instance] applicationWillResignActive];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
    if (!QMApi.instance.isInternetConnected) {
        [REAlertView showAlertWithMessage:NSLocalizedString(@"QM_STR_CHECK_INTERNET_CONNECTION", nil) actionSuccess:NO];
        return;
    }
    if (!QMApi.instance.currentUser) {
        return;
    }
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [[QMApi instance] applicationDidBecomeActive:^(BOOL success) {}];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
    [FBSDKAppEvents activateApp];
}

- (void)applicationWillTerminate:(UIApplication *)application {

}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {

    BOOL urlWasIntendedForFacebook = [[FBSDKApplicationDelegate sharedInstance] application:application
                                                                                    openURL:url
                                                                          sourceApplication:sourceApplication
                                                                                 annotation:annotation
                                      ];
    return urlWasIntendedForFacebook;
}


#pragma mark - PUSH NOTIFICATIONS REGISTRATION

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    if (deviceToken) {
        [[QMApi instance] setDeviceToken:deviceToken];
    }
}

#pragma mark - QMNotificationHandlerDelegate protocol

- (void)notificationHandlerDidSucceedFetchingDialog:(QBChatDialog *)chatDialog {
    UITabBarController *rootController = [(UITabBarController *)self.window.rootViewController selectedViewController];
    UINavigationController *navigationController = (UINavigationController *)rootController;
    
    UIViewController *chatVC = [QMViewControllersFactory chatControllerWithDialog:chatDialog];
    
    NSString *dialogWithIDWasEntered = [QMApi instance].settingsManager.dialogWithIDisActive;
    if (dialogWithIDWasEntered != nil) {
        // some chat already opened, return to dialogs view controller first
        [navigationController popViewControllerAnimated:NO];
    }
    
    [navigationController pushViewController:chatVC animated:YES];
}

@end
