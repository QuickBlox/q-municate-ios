//
//  QMMainTabBarController.m
//  Q-municate
//
//  Created by Igor Alefirenko on 21/02/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMMainTabBarController.h"
#import "SVProgressHUD.h"
#import "QMApi.h"

@interface QMMainTabBarController ()

@end

@implementation QMMainTabBarController


- (void)viewDidLoad {
    [super viewDidLoad];

    [self customizeTabBar];
    [self.navigationController setNavigationBarHidden:YES animated:NO];

//    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    __weak __typeof(self)weakSelf = self;
    [[QMApi instance] autoLogin:^(BOOL success) {
        
        if (!success) {
            [[QMApi instance] logout:^(BOOL logoutSuccess) {
                [weakSelf performSegueWithIdentifier:@"SplashSegue" sender:nil];
            }];
        }else {
            [[QMApi instance] loginChatWithUser:weakSelf.currentUser completion:^(BOOL loginSuccess) {
                [[QMApi instance] fetchAllHistory:^{
                    [SVProgressHUD dismiss];
                }];
            }];
        }
//        [weakSelf.viewControllers makeObjectsPerformSelector:@selector(view)];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)customizeTabBar {
    
    UIColor *white = [UIColor whiteColor];
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : white} forState:UIControlStateNormal];
    self.tabBarController.tabBar.tintColor = white;
    
    UIImage *friendsImg = [[UIImage imageNamed:@"tb_friends"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UITabBarItem *firstTab = self.tabBar.items[0];
    firstTab.image = friendsImg;
    firstTab.selectedImage = friendsImg;
    
    UIImage *chatImg = [[UIImage imageNamed:@"tb_chat"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UITabBarItem *chatTab = self.tabBar.items[1];
    chatTab.image = chatImg;
    chatTab.selectedImage = chatImg;
    
    UIImage *inviteImg = [[UIImage imageNamed:@"tb_invite"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UITabBarItem *inviteTab = self.tabBar.items[2];
    inviteTab.image = inviteImg;
    inviteTab.selectedImage = inviteImg;
    
    UIImage *settingsImg = [[UIImage imageNamed:@"tb_settings"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UITabBarItem *fourthTab = self.tabBar.items[3];
    fourthTab.image = settingsImg;
    fourthTab.selectedImage = settingsImg;
    
    for (UINavigationController *navViewController in self.viewControllers ) {
        NSAssert([navViewController isKindOfClass:[UINavigationController class]], @"is not UINavigationController");
        [navViewController.viewControllers makeObjectsPerformSelector:@selector(view)];
    }
}

@end
