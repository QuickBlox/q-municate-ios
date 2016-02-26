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

// Production
const NSUInteger kQMApplicationID = 13318;
NSString *const kQMAuthorizationKey = @"WzrAY7vrGmbgFfP";
NSString *const kQMAuthorizationSecret = @"xS2uerEveGHmEun";
NSString *const kQMAccountKey = @"6Qyiz3pZfNsex1Enqnp7";

@interface AppDelegate () <QMNotificationHandlerDelegate>

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    UIApplication.sharedApplication.applicationIconBadgeNumber = 0;
    
    UIApplication.sharedApplication.statusBarStyle = UIStatusBarStyleDefault;
    
    self.window.backgroundColor = [UIColor whiteColor];
    
    // QB Settings
    [QBSettings setApplicationID:kQMApplicationID];
    [QBSettings setAuthKey:kQMAuthorizationKey];
    [QBSettings setAuthSecret:kQMAuthorizationSecret];
    [QBSettings setAccountKey:kQMAccountKey];
    [QBSettings setLogLevel:QBLogLevelDebug];
    [QBSettings enableXMPPLogging];
    
    //QuickbloxWebRTC preferences
    [QBRTCClient initializeRTC];
    [QBRTCConfig setICEServers:[self quickbloxICE]];
    [QBRTCConfig mediaStreamConfiguration].audioCodec = QBRTCAudioCodecISAC;
    [QBRTCConfig setStatsReportTimeInterval:0.0f]; // set to 1.0f to enable stats report
    
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else{
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound];
    }
    
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
            
            // calling dispatch async for push notification handling to have priority in main queue
            dispatch_async(dispatch_get_main_queue(), ^{
                [[QMApi instance] handlePushNotificationWithDelegate:self];
            });
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
    if (![QBChat instance].isConnected) [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
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

#pragma mark - ICE servers

- (NSArray *)quickbloxICE {
    
    NSString *password = @"baccb97ba2d92d71e26eb9886da5f1e0";
    NSString *userName = @"quickblox";
    
    NSArray *urls = @[
                      @"turn.quickblox.com",            //USA
                      @"turnsingapore.quickblox.com",   //Singapore
                      @"turnireland.quickblox.com"      //Ireland
                      ];
    
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:urls.count];
    
    for (NSString *url in urls) {
        
        QBRTCICEServer *stunServer = [QBRTCICEServer serverWithURL:[NSString stringWithFormat:@"stun:%@", url]
                                                          username:@""
                                                          password:@""];
        
        
        QBRTCICEServer *turnUDPServer = [QBRTCICEServer serverWithURL:[NSString stringWithFormat:@"turn:%@:3478?transport=udp", url]
                                                             username:userName
                                                             password:password];
        
        QBRTCICEServer *turnTCPServer = [QBRTCICEServer serverWithURL:[NSString stringWithFormat:@"turn:%@:3478?transport=tcp", url]
                                                             username:userName
                                                             password:password];
        
        [result addObjectsFromArray:@[stunServer, turnTCPServer, turnUDPServer]];
    }
    
    return result;
}

@end
