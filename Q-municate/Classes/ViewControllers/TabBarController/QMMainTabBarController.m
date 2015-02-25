//
//  QMMainTabBarController.m
//  Q-municate
//
//  Created by Andrey ivanov on 21/02/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMMainTabBarController.h"
#import "QMTasks.h"

@interface QMMainTabBarController ()

@end

@implementation QMMainTabBarController

- (void)dealloc {
    NSLog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self customizeTabBar];
    [self.navigationController setNavigationBarHidden:YES
                                             animated:NO];
    [QMTasks taskLogin:^(BOOL loginSuccess) {
        
        if (loginSuccess) {
            
            [QMTasks taskFetchDialogsAndUsers:^(BOOL success) {
                
            }];
        }
    }];
}

- (void)customizeTabBar {

    self.tabBar.tintColor = [UIColor whiteColor];
    
    [self configureTabBarItemWithIndex:0
                         iconImageName:@"tb_chat"];
    
    [self configureTabBarItemWithIndex:1
                         iconImageName:@"tb_friends"];
    
    [self configureTabBarItemWithIndex:2
                         iconImageName:@"tb_invite"];
    
    [self configureTabBarItemWithIndex:3
                         iconImageName:@"tb_settings"];
    
    for (UINavigationController *navViewController in self.viewControllers ) {
        
        NSAssert([navViewController isKindOfClass:[UINavigationController class]], @"is not UINavigationController");
        [navViewController.viewControllers makeObjectsPerformSelector:@selector(view)];
    }
}

- (void)configureTabBarItemWithIndex:(NSUInteger)index
                       iconImageName:(NSString *)iconImageName {
    
    UIImage *iconImage = [UIImage imageNamed:iconImageName];
    UIImage *iconImageWithRenderingMode =
    [iconImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    UITabBarItem *tabBarItem = self.tabBar.items[index];
    
    tabBarItem.image = iconImageWithRenderingMode;
    tabBarItem.selectedImage = iconImageWithRenderingMode;
}

@end
