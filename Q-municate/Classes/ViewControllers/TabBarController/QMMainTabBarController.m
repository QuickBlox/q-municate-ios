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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

@end
