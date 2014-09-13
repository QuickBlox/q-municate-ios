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
            
            [[QMApi instance] loginChat:^(BOOL loginSuccess) {
                [[QMApi instance] subscribeToPushNotificationsForceSettings:NO complete:^(BOOL subscribeToPushNotificationsSuccess) {
                
                    if (!subscribeToPushNotificationsSuccess) {
                        [QMApi instance].settingsManager.pushNotificationsEnabled = NO;
                    }
                }];
                
                QMSettingsManager *settings = [QMApi instance].settingsManager;
                [[QMApi instance] fetchAllHistory:^{}];
                
                if (![settings isFirstFacebookLogin]) {
                    
                    [settings setFirstFacebookLogin:YES];
                    [[QMApi instance] importFriendsFromFacebook];
                    [[QMApi instance] importFriendsFromAddressBook];
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
    self.tabBarController.tabBar.tintColor = white;
    
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
    
    if (message.cParamNotificationType > 0) {
        [self.chatDelegate tabBarChatWithChatMessage:message chatDialog:otherDialog showTMessage:NO];
        return;
    }
    if ([self.chatDelegate isKindOfClass:QMChatViewController.class] && [otherDialog isEqual:((QMChatViewController *)self.chatDelegate).dialog]) {
        [self.chatDelegate tabBarChatWithChatMessage:message chatDialog:otherDialog showTMessage:NO];
        return;
    }
    [self.chatDelegate tabBarChatWithChatMessage:message chatDialog:otherDialog showTMessage:YES];
}


#pragma mark - QMTabBarChatDelegate

- (void)tabBarChatWithChatMessage:(QBChatMessage *)message chatDialog:(QBChatDialog *)dialog showTMessage:(BOOL)show
{
    if (!show) {
        return;
    }
    __block UIImage *img = nil;
    NSString *title = nil;
    
    if (dialog.type ==  QBChatDialogTypeGroup) {
        
        img = [UIImage imageNamed:@"upic_placeholder_details_group"];
        title = dialog.name;
    }
    else if (dialog.type == QBChatDialogTypePrivate) {
        
        NSUInteger occupantID = [[QMApi instance] occupantIDForPrivateChatDialog:dialog];
        QBUUser *user = [[QMApi instance] userWithID:occupantID];
        title = user.fullName;
    }
    [QMSoundManager playMessageReceivedSound];
    [TWMessageBarManager sharedInstance].styleSheet = [QMMessageBarStyleSheetFactory defaultMsgBarWithImage:img];
    [[TWMessageBarManager sharedInstance] showMessageWithTitle:title
                                                   description:message.encodedText
                                                          type:TWMessageBarMessageTypeSuccess];
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
