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
#import "QMChatViewController.h"
#import "QMSoundManager.h"
#import "QMChatDataSource.h"
#import "QMSettingsManager.h"
#import "QMChatReceiver.h"


@interface QMMainTabBarController ()

@end


@implementation QMMainTabBarController


- (void)dealloc
{
    [[QMChatReceiver instance] unsubscribeForTarget:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.chatDelegate = self;
    
    [self customizeTabBar];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    [self subscribeToNotifications];
    __weak __typeof(self)weakSelf = self;
    
    [[QMApi instance] autoLogin:^(BOOL success) {
        if (!success) {
            
            [[QMApi instance] logout:^(BOOL logoutSuccess) {
                [weakSelf performSegueWithIdentifier:@"SplashSegue" sender:nil];
            }];
            
        }else {
            // open app by push notification:
            NSDictionary *push = [[QMApi instance] pushNotification];
            if (push != nil) {
                [SVProgressHUD show];
                [[QMApi instance] openChatPageForPushNotification:push completion:^(BOOL completed) {
                    [SVProgressHUD dismiss];
                }];
                [[QMApi instance] setPushNotification:nil];
            }
            
            // subscribe to push notifications
            [[QMApi instance] subscribeToPushNotificationsForceSettings:NO complete:^(BOOL subscribeToPushNotificationsSuccess) {
                
                if (!subscribeToPushNotificationsSuccess) {
                    [QMApi instance].settingsManager.pushNotificationsEnabled = NO;
                }
            }];
            
            [[QMApi instance] loginChat:^(BOOL loginSuccess) {
                
                QBUUser *usr = [QMApi instance].currentUser;
                if (!usr.imported) {
                    [[QMApi instance] importFriendsFromFacebook];
                    [[QMApi instance] importFriendsFromAddressBookWithCompletion:^(BOOL succeded, NSError *error) {}];
                    usr.imported = YES;
                    [[QMApi instance] updateUser:usr image:nil progress:nil completion:^(BOOL successed) {}];
                    
                } else {
                
                    [[QMApi instance] fetchAllHistory:^{
                        //
                    }];
                }
            }];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setChatDelegate:(id)chatDelegate
{
    if (chatDelegate == nil) {
        _chatDelegate = self;
        return;
    }
    _chatDelegate = chatDelegate;
}

- (void)subscribeToNotifications
{
    __weak typeof(self)weakSelf = self;
    [[QMChatReceiver instance] chatAfterDidReceiveMessageWithTarget:self block:^(QBChatMessage *message) {
        if (message.delayed) {
            return;
        }
        QBChatDialog *dialog = [[QMApi instance] chatDialogWithID:message.cParamDialogID];
        [weakSelf message:message forOtherDialog:dialog];
    }];
}

- (void)customizeTabBar {
    
    UIColor *white = [UIColor whiteColor];
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : white} forState:UIControlStateNormal];
    
    UITabBar *tabBar = self.tabBarController.tabBar;
    tabBar.tintColor = white;
    
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
    
    for (UINavigationController *navViewController in self.viewControllers ) {
        NSAssert([navViewController isKindOfClass:[UINavigationController class]], @"is not UINavigationController");
        [navViewController.viewControllers makeObjectsPerformSelector:@selector(view)];
    }
}

#pragma mark - QMChatDataSourceDelegate

- (void)message:(QBChatMessage *)message forOtherDialog:(QBChatDialog *)otherDialog {
    
    // if message is not mine:
    if (message.senderID != [QMApi instance].currentUser.ID) {
        
        if ([self.chatDelegate isKindOfClass:QMChatViewController.class] && [otherDialog.ID isEqual:((QMChatViewController *)self.chatDelegate).dialog.ID]) {
            // don't show popup
            [self tabBarChatWithChatMessage:message chatDialog:otherDialog showTMessage:NO];
        } else {
            [self tabBarChatWithChatMessage:message chatDialog:otherDialog showTMessage:YES];
        }
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
            QMChatViewController *chatController = [weakSelf.storyboard instantiateViewControllerWithIdentifier:@"QMChatViewController"];
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
