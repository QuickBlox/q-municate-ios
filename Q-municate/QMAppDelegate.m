//
//  AppDelegate.m
//  Q-municate
//
//  Created by Injoit on 13/02/2014.
//  Copyright © 2014 QuickBlox. All rights reserved.
//

#import "QMAppDelegate.h"
#import "QMCore.h"
#import "QMImages.h"
#import "QMColors.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "UIScreen+QMLock.h"
#import "UIImage+Cropper.h"
#import "QBSettings+Qmunicate.h"

#import <Intents/Intents.h>
#import <Flurry_iOS_SDK/Flurry.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FirebaseCore/FirebaseCore.h>
#import <FirebaseAuth/FirebaseAuth.h>

@interface QMAppDelegate () <QMPushNotificationManagerDelegate, QMAuthServiceDelegate>

@end

@implementation QMAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    application.applicationIconBadgeNumber = 0;
    
    // QuickBlox settings
    [QBSettings configure];
    [QMServicesManager enableLogging:QMCurrentApplicationZone != QMApplicationZoneProduction];
    
    // QuickBloxWebRTC settings
    [QBRTCClient initializeRTC];
    [QBRTCConfig mediaStreamConfiguration].audioCodec = QBRTCAudioCodecOpus;
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
    
    [SVProgressHUD setBorderWidth:1];
    [SVProgressHUD setBorderColor:[[UIColor grayColor] colorWithAlphaComponent:0.1]];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    
    // Configuring external frameworks
    [FIRApp configure];
    [[FIRAuth auth] useAppLanguage];
    [Flurry startSession:@"P8NWM9PBFCK2CWC8KZ59"];
    [Flurry logEvent:@"connect_to_chat"
      withParameters:@{@"app_id" : [NSString stringWithFormat:@"%tu", QBSettings.applicationID],
                       @"chat_endpoint" : [QBSettings chatEndpoint]}];
    
    // not returning this method as launch options are not ONLY related to facebook
    // for example when facebook returns NO in this method, callkit call from contacts
    // app will not be handled. Facebook should not decide if URL should be handled for everything
    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];
    
    return YES;
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    
    if ([[FIRAuth auth] canHandleNotification:userInfo]) {
        completionHandler(UIBackgroundFetchResultNoData);
        return;
    }
    
    if (application.applicationState == UIApplicationStateInactive) {
        
        NSString *dialogID = userInfo[kQMPushNotificationDialogIDKey];
        NSString *activeDialogID = [QMCore instance].activeDialogID;
        if ([dialogID isEqualToString:activeDialogID]) {
            // dialog is already active
            return;
        }
        
        [QMCore instance].pushNotificationManager.pushNotification = userInfo;
        // calling dispatch async for push notification handling to have priority in main queue
        [[QMCore instance].pushNotificationManager handlePushNotificationWithDelegate:self];
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    application.applicationIconBadgeNumber = 0;
    [QMCore.instance.chatManager disconnectFromChatIfNeeded];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // sending presence after application becomes active,
    // or just restoring state if chat is disconnected
    if (QBChat.instance.manualInitialPresence) {
        QBChat.instance.manualInitialPresence = NO;
    }
    // connect to chat now
    [QMCore.instance login];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
    [FBSDKAppEvents activateApp];
}
- (BOOL)application:(UIApplication *)app
            openURL:(NSURL *)url
            options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options {
    BOOL urlWasIntendedForFacebook =
    [[FBSDKApplicationDelegate sharedInstance] application:app
                                                   openURL:url
                                                   options:options];
    return urlWasIntendedForFacebook;
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    
    return [[UIScreen mainScreen] qm_allowedInterfaceOrientationMask];
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    [[QMCore instance].pushNotificationManager updateToken:deviceToken];
    FIRAuthAPNSTokenType firTokenType;
    
    if (QMCurrentApplicationZone == QMApplicationZoneProduction) {
        firTokenType = FIRAuthAPNSTokenTypeProd;
    }
    else {
        firTokenType = FIRAuthAPNSTokenTypeSandbox;
    }
    
    [[FIRAuth auth] setAPNSToken:deviceToken type:firTokenType];
}

- (void)application:(UIApplication *)application
didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    
    [[QMCore instance].pushNotificationManager handleError:error];
}

- (void)application:(UIApplication *)application
handleActionWithIdentifier:(NSString *)identifier
forRemoteNotification:(NSDictionary *)userInfo
   withResponseInfo:(NSDictionary *)responseInfo
  completionHandler:(void (^)())completionHandler {
    
    [[QMCore instance].pushNotificationManager handleActionWithIdentifier:identifier
                                                       remoteNotification:userInfo
                                                             responseInfo:responseInfo
                                                        completionHandler:completionHandler];
}

- (BOOL)application:(UIApplication *)application
continueUserActivity:(NSUserActivity *)userActivity
 restorationHandler:(void(^)(NSArray<id<UIUserActivityRestoring>> * __nullable restorableObjects))restorationHandler {
    
    BOOL isCallIntent = [userActivity.activityType isEqualToString:INStartAudioCallIntentIdentifier] || [userActivity.activityType isEqualToString:INStartVideoCallIntentIdentifier];
    if (isCallIntent) {
        [QMCore.instance.callManager handleUserActivityWithCallIntent:userActivity];
    }
    
    return YES;
}

//MARK: - QMPushNotificationManagerDelegate protocol

- (void)pushNotificationManager:(QMPushNotificationManager *)pushNotificationManager didSucceedFetchingDialog:(QBChatDialog *)chatDialog {
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
