//
//  AppDelegate.m
//  Q-municate
//
//  Created by Igor Alefirenko on 13/02/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMAppDelegate.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "QMChatVC.h"
#import "QMCore.h"
#import "QMImages.h"
#import "QBChatDialog+OpponentID.h"
#import "QMMessagesFactory.h"

#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import <DigitsKit/DigitsKit.h>
#import <Flurry.h>
#import <SVProgressHUD.h>

@import UserNotifications;

static NSString * const kQMNotificationActionTextAction = @"TEXT_ACTION";
static NSString * const kQMNotificationCategoryReply = @"TEXT_REPLY";

#define DEVELOPMENT 1

#if DEVELOPMENT == 0

// Production
static const NSUInteger kQMApplicationID = 13318;
static NSString * const kQMAuthorizationKey = @"WzrAY7vrGmbgFfP";
static NSString * const kQMAuthorizationSecret = @"xS2uerEveGHmEun";
static NSString * const kQMAccountKey = @"6Qyiz3pZfNsex1Enqnp7";

#else

// Development
static const NSUInteger kQMApplicationID = 36125;
static NSString * const kQMAuthorizationKey = @"gOGVNO4L9cBwkPE";
static NSString * const kQMAuthorizationSecret = @"JdqsMHCjHVYkVxV";
static NSString * const kQMAccountKey = @"6Qyiz3pZfNsex1Enqnp7";

#endif

@interface QMAppDelegate () <QMPushNotificationManagerDelegate, UNUserNotificationCenterDelegate>

@end

@implementation QMAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    application.applicationIconBadgeNumber = 0;
    
    // Quickblox settings
    [QBSettings setApplicationID:kQMApplicationID];
    [QBSettings setAuthKey:kQMAuthorizationKey];
    [QBSettings setAuthSecret:kQMAuthorizationSecret];
    [QBSettings setAccountKey:kQMAccountKey];
    
    [QBSettings setAutoReconnectEnabled:YES];
    [QBSettings setCarbonsEnabled:YES];
    
#if DEVELOPMENT == 0
    [QBSettings setLogLevel:QBLogLevelNothing];
    [QBSettings disableXMPPLogging];
    [QMServicesManager enableLogging:NO];
#else
    [QBSettings setLogLevel:QBLogLevelDebug];
    [QBSettings enableXMPPLogging];
    [QMServicesManager enableLogging:YES];
#endif
    
    // QuickbloxWebRTC settings
    [QBRTCClient initializeRTC];
    [QBRTCConfig setICEServers:[[QMCore instance].callManager quickbloxICE]];
    [QBRTCConfig mediaStreamConfiguration].audioCodec = QBRTCAudioCodecISAC;
    [QBRTCConfig setStatsReportTimeInterval:0.0f]; // set to 1.0f to enable stats report
    
    // Registering for remote notifications
    [self registerForNotification];
    
    // Configuring app appearance
    UIColor *mainTintColor = [UIColor colorWithRed:13.0f/255.0f green:112.0f/255.0f blue:179.0f/255.0f alpha:1.0f];
    [[UINavigationBar appearance] setTintColor:mainTintColor];
    [[UISearchBar appearance] setTintColor:mainTintColor];
    [[UITabBar appearance] setTintColor:mainTintColor];
    
    // Configuring searchbar appearance
    [[UISearchBar appearance] setSearchBarStyle:UISearchBarStyleMinimal];
    [[UISearchBar appearance] setBarTintColor:[UIColor whiteColor]];
    [[UISearchBar appearance] setBackgroundImage:QMStatusBarBackgroundImage() forBarPosition:0 barMetrics:UIBarMetricsDefault];
    
    [SVProgressHUD setBackgroundColor:[[UIColor whiteColor] colorWithAlphaComponent:0.92f]];
    
    // Configuring external frameworks
    [Fabric with:@[CrashlyticsKit, DigitsKit]];
    [Flurry startSession:@"P8NWM9PBFCK2CWC8KZ59"];
    [Flurry logEvent:@"connect_to_chat" withParameters:@{@"app_id" : [NSString stringWithFormat:@"%tu", kQMApplicationID],
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


#pragma mark - Push notification registration

- (void)registerForNotification {
    
    if ([UNUserNotificationCenter class]) {
        
        // subscribing for delegate
        [UNUserNotificationCenter currentNotificationCenter].delegate = self;
        
        // adding text action
        UNTextInputNotificationAction *textAction = [UNTextInputNotificationAction actionWithIdentifier:kQMNotificationActionTextAction title:@"Reply" options:UNNotificationActionOptionNone textInputButtonTitle:@"Reply" textInputPlaceholder:NSLocalizedString(@"QM_STR_INPUTTOOLBAR_PLACEHOLDER", nil)];
        UNNotificationCategory *notificationCategory = [UNNotificationCategory categoryWithIdentifier:kQMNotificationCategoryReply actions:@[textAction] intentIdentifiers:@[] options:UNNotificationCategoryOptionNone];
        
        [[UNUserNotificationCenter currentNotificationCenter] setNotificationCategories:[NSSet setWithObject:notificationCategory]];
        [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:(UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert) completionHandler:^(BOOL __unused granted, NSError * __unused _Nullable error) {}];
    }
    else {
        
        UIMutableUserNotificationAction *textAction = [[UIMutableUserNotificationAction alloc] init];
        textAction.identifier = kQMNotificationActionTextAction;
        textAction.title = @"Reply";
        textAction.activationMode = UIUserNotificationActivationModeBackground;
        textAction.authenticationRequired = NO;
        textAction.destructive = NO;
        textAction.behavior = UIUserNotificationActionBehaviorTextInput;
        
        UIMutableUserNotificationCategory *category = [[UIMutableUserNotificationCategory alloc] init];
        category.identifier = kQMNotificationCategoryReply;
        [category setActions:@[textAction] forContext:UIUserNotificationActionContextDefault];
        [category setActions:@[textAction] forContext:UIUserNotificationActionContextMinimal];
        
        UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings
                                                            settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge)
                                                            categories:[NSSet setWithObject:category]];
        [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
    }
    
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}

- (void)application:(UIApplication *)__unused application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    [QMCore instance].pushNotificationManager.deviceToken = deviceToken;
}

//- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void (^)())completionHandler {
//
//}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo withResponseInfo:(NSDictionary *)responseInfo completionHandler:(void (^)())completionHandler {
    
    if ([identifier isEqualToString:kQMNotificationActionTextAction]) {
        
        
    }
    
    if (completionHandler) {
        
        completionHandler();
    }
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    
    if ([response.actionIdentifier isEqualToString:kQMNotificationActionTextAction]) {
        
        NSString *dialogID = response.notification.request.content.userInfo[kQMPushNotificationDialogIDKey];
        
        UIApplication *application = [UIApplication sharedApplication];
        __block UIBackgroundTaskIdentifier task = [application beginBackgroundTaskWithExpirationHandler:^{
            
            [[QMCore instance].chatService disconnect];
            
            [application endBackgroundTask:task];
            task = UIBackgroundTaskInvalid;
        }];
        
        //        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        // Do the work associated with the task.
        NSLog(@"Started background task timeremaining = %f", [application backgroundTimeRemaining]);
        
        QBChatDialog *chatDialog = [[QMCore instance].chatService.dialogsMemoryStorage chatDialogWithID:dialogID];
        if (chatDialog != nil) {
            
            if (chatDialog.type == QBChatDialogTypePrivate
                && ![[QMCore instance].contactManager isFriendWithUserID:[chatDialog opponentID]]) {
                
                if (completionHandler) {
                    
                    completionHandler();
                }
                
                return;
            }
            
            [[[[[QMCore instance].chatService connect] continueWithBlock:^id _Nullable(BFTask * _Nonnull __unused t) {
                
                NSUInteger currentUserID = [QMCore instance].currentProfile.userData.ID;
                
                QBChatMessage *message = [QMMessagesFactory chatMessageWithText:[(UNTextInputNotificationResponse *)response userText]
                                                                       senderID:currentUserID
                                                                   chatDialogID:chatDialog.ID
                                                                       dateSent:[NSDate date]];
                
                return [[QMCore instance].chatService sendMessage:message toDialog:chatDialog saveToHistory:YES saveToStorage:YES];
                
            }] continueWithBlock:^id _Nullable(BFTask * _Nonnull __unused t) {
                
                return [[QMCore instance].chatService disconnect];
                
            }] continueWithBlock:^id _Nullable(BFTask * _Nonnull __unused t) {
                
                [application endBackgroundTask:task];
                task = UIBackgroundTaskInvalid;
                
                return nil;
            }];
        }
        //        });
    }
    
    if (completionHandler) {
        
        completionHandler();
    }
}

#pragma mark - QMPushNotificationManagerDelegate protocol

- (void)pushNotificationManager:(QMPushNotificationManager *)__unused pushNotificationManager didSucceedFetchingDialog:(QBChatDialog *)chatDialog {
    
    UITabBarController *tabBarController = (UITabBarController *)self.window.rootViewController;
    UINavigationController *navigationController = (UINavigationController *)tabBarController.selectedViewController;
    
    NSString *activeDialogID = [QMCore instance].activeDialogID;
    if ([chatDialog.ID isEqualToString:activeDialogID]) {
        // dialog is already active
        return;
    }
    
    QMChatVC *chatVC = [QMChatVC chatViewControllerWithChatDialog:chatDialog];
    [navigationController pushViewController:chatVC animated:YES];
}

@end
