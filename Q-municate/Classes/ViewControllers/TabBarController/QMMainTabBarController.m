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
#import "QMImageView.h"
#import "TWMessageBarManager.h"
#import "QMMessageBarStyleSheetFactory.h"
#import "QMSoundManager.h"
#import "QMChatDataSource.h"
#import "QMSettingsManager.h"


@interface QMMainTabBarController ()

@end

@implementation QMMainTabBarController


- (void)viewDidLoad {
    [super viewDidLoad];

    [self customizeTabBar];
    [self.navigationController setNavigationBarHidden:YES animated:NO];

    __weak __typeof(self)weakSelf = self;
    [[QMApi instance] autoLogin:^(BOOL success) {
        
        if (!success) {
            
            [[QMApi instance] logout:^(BOOL logoutSuccess) {
                [weakSelf performSegueWithIdentifier:@"SplashSegue" sender:nil];
            }];
            
        }else {
            
            [[QMApi instance] loginChat:^(BOOL loginSuccess) {
                [[QMApi instance] subscribeToPushNotifications];
                
                QMSettingsManager *settings = [QMApi instance].settingsManager;
                [[QMApi instance] fetchAllHistory:^{}];
                
                if (![settings isFirstFacebookLogin]) {
                    
                    [settings setFirstFacebookLogin:YES];
                    [[QMApi instance] importFriendsFromFacebook];
                    [[QMApi instance] importFriendsFromAddressBook];
                    
                    return;
                }
                
            }];
        }
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

#pragma mark - QMChatDataSourceDelegate

- (void)message:(QBChatMessage *)message forOtherOtherDialog:(QBChatDialog *)otherDialog {
    
    __block UIImage *img = nil;
    NSString *title = nil;
    
    if (otherDialog.type ==  QBChatDialogTypeGroup) {
        
        img = [UIImage imageNamed:@"upic_placeholder_details_group"];
        title = otherDialog.name;
    }
    else if (otherDialog.type == QBChatDialogTypePrivate) {
        
        NSUInteger occupantID = [[QMApi instance] occupantIDForPrivateChatDialog:otherDialog];
        QBUUser *user = [[QMApi instance] userWithID:occupantID];
        title = user.fullName;
        
//        [QMImageView imageWithURL:[NSURL URLWithString:user.website]
//                             size:CGSizeMake(50, 50)
//                         progress:nil
//                             type:QMImageViewTypeCircle
//                       completion:^(UIImage *userAvatar) {
//                           img = userAvatar;
//                       }];
//        if (!img) {
//            img = [UIImage imageNamed:@"upic-placeholder"];
//        }
        
    }
    [QMSoundManager playMessageReceivedSound];
    [TWMessageBarManager sharedInstance].styleSheet = [QMMessageBarStyleSheetFactory defaultMsgBarWithImage:img];
    [[TWMessageBarManager sharedInstance] showMessageWithTitle:title
                                                   description:message.text
                                                          type:TWMessageBarMessageTypeSuccess];
}

@end
