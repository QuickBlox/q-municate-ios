//
//  AppDelegate.m
//  Q-municate
//
//  Created by Igor Alefirenko on 13/02/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMAppDelegate.h"
#import "QMCore.h"
#import "QMImages.h"
#import "QMColors.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import <Flurry.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import <Intents/Intents.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FirebaseCore/FirebaseCore.h>
#import <FirebaseAuth/FirebaseAuth.h>

#import "UIScreen+QMLock.h"
#import "UIImage+Cropper.h"
#import "QBSettings+Qmunicate.h"

@interface QMAppDelegate () <QMPushNotificationManagerDelegate, QMAuthServiceDelegate>

@end

@implementation QMAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    application.applicationIconBadgeNumber = 0;
    
    // Quickblox settings
    [QBSettings configureForQmunicate];
    
#if DEVELOPMENT == 0
    [QBSettings setLogLevel:QBLogLevelNothing];
    [QBSettings disableXMPPLogging];
    [QMServicesManager enableLogging:NO];
    
    QMLogSetEnabled(NO);
#else
    [QBSettings setLogLevel:QBLogLevelDebug];
    [QBSettings enableXMPPLogging];
    [QMServicesManager enableLogging:YES];
    
    QMLogSetEnabled(YES);
#endif
    
    // QuickbloxWebRTC settings
    [QBRTCClient initializeRTC];
    [QBRTCConfig mediaStreamConfiguration].audioCodec = QBRTCAudioCodecISAC;
    [QBRTCConfig setStatsReportTimeInterval:0.0f]; // set to 1.0f to enable stats report
    
    // Configuring app appearance
    [[UITabBar appearance] setTintColor:QMMainApplicationColor()];
    [[UINavigationBar appearance] setTintColor:QMSecondaryApplicationColor()];

    // Configuring searchbar appearance

    [[UISearchBar appearance] setSearchBarStyle:UISearchBarStyleMinimal];
    [[UISearchBar appearance] setBarTintColor:[UIColor whiteColor]];
    [[UISearchBar appearance] setBackgroundImage:QMStatusBarBackgroundImage() forBarPosition:0 barMetrics:UIBarMetricsDefault];
    
    [[UITextField appearance] setTintColor:QMSecondaryApplicationColor()];
    [UITextField appearance].keyboardAppearance = UIKeyboardAppearanceDark;
    
    [SVProgressHUD setBackgroundColor:[[UIColor whiteColor] colorWithAlphaComponent:0.92f]];
    // Configuring external frameworks
    [FIRApp configure];
    [[FIRAuth auth] useAppLanguage];
    [Fabric with:@[CrashlyticsKit]];
    [Flurry startSession:@"P8NWM9PBFCK2CWC8KZ59"];
    [Flurry logEvent:@"connect_to_chat" withParameters:@{@"app_id" : [NSString stringWithFormat:@"%tu", QBSettings.applicationID],
                                                         @"chat_endpoint" : [QBSettings chatEndpoint]}];
    
    // Handling push notifications if needed
    if (launchOptions != nil) {
        NSDictionary *pushNotification = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
        [QMCore instance].pushNotificationManager.pushNotification = pushNotification;
    }
    
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                    didFinishLaunchingWithOptions:launchOptions];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    if (application.applicationState == UIApplicationStateInactive) {
        
        NSString *dialogID = userInfo[kQMPushNotificationDialogIDKey];
        NSString *activeDialogID = [QMCore instance].activeDialogID;
        if ([dialogID isEqualToString:activeDialogID]) {
            // dialog is already active
            return;
        }
        
        [QMCore instance].pushNotificationManager.pushNotification = userInfo;
        // calling dispatch async for push notification handling to have priority in main queue
        dispatch_async(dispatch_get_main_queue(), ^{
            [[QMCore instance].pushNotificationManager handlePushNotificationWithDelegate:self];
        });
    }
}

- (void)application:(UIApplication *)__unused application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    if ([[FIRAuth auth] canHandleNotification:userInfo]) {
        completionHandler(UIBackgroundFetchResultNoData);
        return;
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
    application.applicationIconBadgeNumber = 0;
    [[QMCore instance].chatManager disconnectFromChatIfNeeded];
}

- (void)applicationWillEnterForeground:(UIApplication *)__unused application {
    
    [[QMCore instance] login];
}

- (void)applicationDidBecomeActive:(UIApplication *)__unused application {
    
    [FBSDKAppEvents activateApp];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    BOOL urlWasIntendedForFacebook = [[FBSDKApplicationDelegate sharedInstance] application:application
                                                                                    openURL:url
                                                                          sourceApplication:sourceApplication
                                                                                 annotation:annotation];
    return urlWasIntendedForFacebook;
}

- (UIInterfaceOrientationMask)application:(UIApplication *)__unused application supportedInterfaceOrientationsForWindow:(UIWindow *)__unused window {
    
    return [[UIScreen mainScreen] qm_allowedInterfaceOrientationMask];
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)__unused notificationSettings {
    
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)__unused application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [[QMCore instance].pushNotificationManager updateToken:deviceToken];
    FIRAuthAPNSTokenType firTokenType;
#if DEVELOPMENT == 0
    firTokenType = FIRAuthAPNSTokenTypeProd;
#else
    firTokenType = FIRAuthAPNSTokenTypeSandbox;
#endif

    [[FIRAuth auth] setAPNSToken:deviceToken type:firTokenType];
}

- (void)application:(UIApplication *)__unused application
didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    [[QMCore instance].pushNotificationManager handleError:error];
}

- (void)application:(UIApplication *)__unused application
handleActionWithIdentifier:(NSString *)identifier
forRemoteNotification:(NSDictionary *)userInfo
   withResponseInfo:(NSDictionary *)responseInfo
  completionHandler:(void (^)())completionHandler {
    
    [[QMCore instance].pushNotificationManager handleActionWithIdentifier:identifier
                                                       remoteNotification:userInfo
                                                             responseInfo:responseInfo
                                                        completionHandler:completionHandler];
}

//MARK: - QMPushNotificationManagerDelegate protocol

- (void)pushNotificationManager:(QMPushNotificationManager *)__unused pushNotificationManager didSucceedFetchingDialog:(QBChatDialog *)chatDialog {
    
    UITabBarController *tabBarController = [[(UISplitViewController *)self.window.rootViewController viewControllers] firstObject];
    UIViewController *dialogsVC = [[(UINavigationController *)[[tabBarController viewControllers] firstObject] viewControllers] firstObject];
    
    NSString *activeDialogID = [QMCore instance].activeDialogID;
    if ([chatDialog.ID isEqualToString:activeDialogID]) {
        // dialog is already active
        return;
    }
    
    [dialogsVC performSegueWithIdentifier:kQMSceneSegueChat sender:chatDialog];
}

@end
