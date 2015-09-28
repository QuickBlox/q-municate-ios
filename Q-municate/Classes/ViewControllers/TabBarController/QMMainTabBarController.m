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
#import "MPGNotification.h"
#import "QMMessageBarStyleSheetFactory.h"
#import "QMChatVC.h"
#import "QMSoundManager.h"
#import "QMSettingsManager.h"
#import "REAlertView+QMSuccess.h"
#import "QMDevice.h"


@interface QMMainTabBarController ()

@end


@implementation QMMainTabBarController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (![[QBChat instance] isLoggedIn]) {
        // show hud and start login to chat:
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    }
}

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
            
        } else {
            
            // open app by push notification:
            NSDictionary *push = [[QMApi instance] pushNotification];
        
            if (push != nil) {
                if( push[@"dialog_id"] ){
                    
                    [SVProgressHUD show];
                    
                    [[QMApi instance] openChatPageForPushNotification:push completion:^(BOOL completed) {
                        [SVProgressHUD dismiss];
                    }];
                    
                    [[QMApi instance] setPushNotification:nil];
                }
            }
            
            // subscribe to push notifications
            [[QMApi instance] subscribeToPushNotificationsForceSettings:NO complete:^(BOOL subscribeToPushNotificationsSuccess) {
                
                if (!subscribeToPushNotificationsSuccess) {
                    [QMApi instance].settingsManager.pushNotificationsEnabled = NO;
                }
            }];
            
            [[QMApi instance] fetchAllHistory:^{
                [weakSelf loginToChat];
            }];
            
        }
    }];
}

- (void)loginToChat
{
    [[QMApi instance] loginChat:^(BOOL loginSuccess) {
        
        // hide progress hud
        [SVProgressHUD dismiss];
        
        [[QMApi instance] joinGroupDialogs];
        QBUUser *usr = [QMApi instance].currentUser;
        if (!usr.isImport) {
            [[QMApi instance] importFriendsFromFacebook];
            [[QMApi instance] importFriendsFromAddressBookWithCompletion:^(BOOL succeded, NSError *error) {
            }];
            usr.isImport = YES;
            QBUpdateUserParameters *params = [QBUpdateUserParameters new];
            params.customData = usr.customData;
            [[QMApi instance] updateCurrentUser:params image:nil progress:nil completion:^(BOOL success) {}];
            
        } else {
            
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)customizeTabBar {
    
    UIColor *white = [UIColor whiteColor];
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : white} forState:UIControlStateNormal];
    
//    UITabBar *tabBar = self.tabBarController.tabBar;
//    tabBar.tintColor = white;
    
    UIImage *chatImg = [[UIImage imageNamed:@"tb_chat"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UITabBarItem *firstTab = self.tabBar.items[0];
    firstTab.image = chatImg;
    firstTab.selectedImage = chatImg;
    
    UIImage *friendsImg = [[UIImage imageNamed:@"tb_friends"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UITabBarItem *chatTab = self.tabBar.items[1];
    chatTab.image = friendsImg;
    chatTab.selectedImage = friendsImg;
    
    UIImage *inviteImg = [[UIImage imageNamed:@"tb_invite"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UITabBarItem *inviteTab = self.tabBar.items[2];
    inviteTab.image = inviteImg;
    inviteTab.selectedImage = inviteImg;
    
    UIImage *settingsImg = [[UIImage imageNamed:@"tb_settings"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UITabBarItem *fourthTab = self.tabBar.items[3];
    fourthTab.image = settingsImg;
    fourthTab.selectedImage = settingsImg; 
    
    // selection image:
    UIImage *tabSelectionImage = nil;
    if ([QMDevice isIphone6] || [QMDevice isIphone6Plus]) {
        tabSelectionImage = [UIImage imageNamed:@"iphone6_tab_fone"];
    } else {
        tabSelectionImage = [UIImage imageNamed:@"tab_fone"];
    }
    self.tabBar.selectionIndicatorImage = tabSelectionImage;
    
    for (UINavigationController *navViewController in self.viewControllers ) {
        NSAssert([navViewController isKindOfClass:[UINavigationController class]], @"is not UINavigationController");
        [navViewController.viewControllers makeObjectsPerformSelector:@selector(view)];
    }
}

#pragma mark - QMChatDataSourceDelegate

- (void)message:(QBChatMessage *)message forOtherDialog:(QBChatDialog *)otherDialog {
    
    // if message is not mine:
    if (message.senderID != [QMApi instance].currentUser.ID) {
        
//        if ([self.chatDelegate isKindOfClass:QMChatVC.class] && [otherDialog.ID isEqual:((QMChatVC *)self.chatDelegate).dialog.ID]) {
//            // don't show popup
//            [self tabBarChatWithChatMessage:message chatDialog:otherDialog showTMessage:NO];
//        } else {
            [self tabBarChatWithChatMessage:message chatDialog:otherDialog showTMessage:YES];
//        }
    }
}


#pragma mark - QMTabBarChatDelegate

- (void)tabBarChatWithChatMessage:(QBChatMessage *)message chatDialog:(QBChatDialog *)dialog showTMessage:(BOOL)show
{
    if (!show) {
        return;
    }
    [QMSoundManager playMessageReceivedSound];
    
    __weak typeof(self) weakSelf = self;
    [QMMessageBarStyleSheetFactory showMessageBarNotificationWithMessage:message chatDialog:dialog completionBlock:^(MPGNotification *notification, NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            UINavigationController *navigationController = (UINavigationController *)[weakSelf selectedViewController];
            QMChatVC *chatController = [weakSelf.storyboard instantiateViewControllerWithIdentifier:@"QMChatVC"];
            chatController.dialog = dialog;
            [navigationController pushViewController:chatController animated:YES];
        }
    }];
    
}


#pragma mark - QMTabBarDelegate

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    UITabBarItem *neededTab = tabBar.items[1];
    if ([item isEqual:neededTab]) {
        if ([self.tabDelegate respondsToSelector:@selector(friendsListTabWasTapped:)]) {
            [self.tabDelegate friendsListTabWasTapped:item];
        }
    }
}

@end
