//
//  AppDelegate.m
//  Q-municate
//
//  Created by Igor Alefirenko on 13/02/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "AppDelegate.h"

#define TEST_QMDBStore 1

#ifdef TEST_QMDBStore
#import "QMDBStorage+Users.h"
#endif

@implementation AppDelegate

#ifdef TEST_QMDBStore

- (void)testQMDBStorage {
    
//   [QMDBStorage cleanDBWithName:@"AndreyIvanov"];
   
   [QMDBStorage setupWithName:@"AndreyIvanov"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        NSMutableArray *users = [NSMutableArray array];
        for (NSUInteger i = 0; i < 10; i++) {
            QBUUser *user = [QBUUser user];
            user.ID = i;
            user.fullName = [NSString stringWithFormat:@"User %d", i];
            [users addObject:user];
        }
        
        dispatch_semaphore_t dsema = dispatch_semaphore_create(0);
        
        [self.dbStorage cacheUsers:users finish:^{
            dispatch_semaphore_signal(dsema);
        }];
        
        dispatch_semaphore_wait(dsema, DISPATCH_TIME_FOREVER);
    });
}
#endif

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

#ifdef TEST_QMDBStore
    [self testQMDBStorage];
#endif
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    // Quickblox credentials
    [QBSettings setApplicationID:7232];
    [QBSettings setAuthorizationKey:@"MpOecRZy-5WsFva"];
    [QBSettings setAuthorizationSecret:@"dTSLaxDsFKqegD7"];
    [QBSettings setAccountKey:@"LpNmxA2Pq2uyW5qBjHy8"];
    
    // STAGE PARAMS
//    [QBSettings setServerChatDomain:@"chatstage.quickblox.com"];
//    [QBSettings setServerApiDomain:@"http://api.stage.quickblox.com"];
//	[QBSettings setContentBucket:@"blobs-test-oz"];

    return YES;
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"Push war received. User info: %@", userInfo);
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types
    // of temporary interruptions (such as an incoming phone call or SMS message) or
    // when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough
    // application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state;
    // here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive.
    // If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    // attempt to extract a token from the url
    return [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication
                    fallbackHandler:^(FBAppCall *call) {
                        ILog(@"In fallback handler");
                    }];
}

@end
