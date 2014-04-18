//
//  QMMainTabBarController.m
//  Q-municate
//
//  Created by Igor Alefirenko on 21/02/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMMainTabBarController.h"
#import "QMSplashViewController.h"
#import "QMUtilities.h"
#import "QMAuthService.h"
#import "QMContactList.h"
#import "QMChatService.h"

@interface QMMainTabBarController ()

@end

@implementation QMMainTabBarController


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self customizeTabBar];
}

- (void)customizeTabBar
{
    UIColor *white = [UIColor whiteColor];
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : white} forState:UIControlStateNormal];
    self.tabBarController.tabBar.tintColor = white;
    
    UITabBarItem *firstTab = [self.tabBar.items objectAtIndex:0];
    firstTab.image = [[UIImage imageNamed:@"tb_friends"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    firstTab.selectedImage = [[UIImage imageNamed:@"tb_friends"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    UITabBarItem *secondTab = [self.tabBar.items objectAtIndex:1];
    secondTab.image = [[UIImage imageNamed:@"tb_chat"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    secondTab.selectedImage = [[UIImage imageNamed:@"tb_chat"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    UITabBarItem *thirdTab = [self.tabBar.items objectAtIndex:2];
    thirdTab.image = [[UIImage imageNamed:@"tb_invite"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    thirdTab.selectedImage = [[UIImage imageNamed:@"tb_invite"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    UITabBarItem *fourthTab = [self.tabBar.items objectAtIndex:3];
    fourthTab.image = [[UIImage imageNamed:@"tb_settings"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    fourthTab.selectedImage = [[UIImage imageNamed:@"tb_settings"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:NO];

    BOOL isLoggedIn = [[[NSUserDefaults standardUserDefaults] objectForKey:kRememberMe] boolValue];
    BOOL isLoggedOut = [[[NSUserDefaults standardUserDefaults] objectForKey:kDidLogout] boolValue];
    if (isLoggedIn && !isLoggedOut) {
        if (![QMAuthService shared].isSessionCreated) {
            [QMUtilities createIndicatorView];
            [[QMAuthService shared] startSessionWithBlock:^(BOOL success, NSError *error) {
                if (success) {
                    NSLog(@"Session created");
                    NSString *email = [[NSUserDefaults standardUserDefaults] objectForKey:kEmail];
                    NSString *password = [[NSUserDefaults standardUserDefaults] objectForKey:kPassword];
                    [[QMAuthService shared] logInWithEmail:email password:password completion:^(QBUUser *user, BOOL success, NSError *error) {
                        if (!success) {
                            NSLog(@"error while logging in: %@", error);
                            [QMUtilities removeIndicatorView];
                            [self showAlertWithMessage:[NSString stringWithFormat:@"%@", error] actionSuccess:NO];
                            return;
                        }
                        [QMContactList shared].me = user;
						if (!user.password) {
						    user.password = password;
						}
                        [[QMChatService shared] loginWithUser:user completion:^(BOOL success) {
                            if (success) {
                                [[QMContactList shared] retrieveFriendsUsingBlock:^(BOOL success) {
									[[NSNotificationCenter defaultCenter] postNotificationName:kFriendsLoadedNotification object:nil];
									[[NSNotificationCenter defaultCenter] postNotificationName:kLoggedInNotification object:nil];
                                    [QMUtilities removeIndicatorView];
                                }];
                            } else {
                                [QMUtilities removeIndicatorView];
                            }
                        }];
                    }];
                } else {
                    [QMUtilities removeIndicatorView];
                    [self showAlertWithMessage:[NSString stringWithFormat:@"%@", error] actionSuccess:NO];
                }
            }];
        }
    } else {
        static dispatch_once_t onceSplashToken;
        dispatch_once(&onceSplashToken, ^{
            [self performSegueWithIdentifier:kSplashSegueIdentifier sender:nil];
        });
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Alert

- (void)showAlertWithMessage:(NSString *)messageString actionSuccess:(BOOL)success
{
    NSString *title = nil;
    if (success) {
        title = kAlertTitleSuccessString;
    } else {
        title = kAlertTitleErrorString;
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:messageString
                                                   delegate:nil
                                          cancelButtonTitle:kAlertButtonTitleOkString
                                          otherButtonTitles:nil];
    [alert show];
}

@end
