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
#import "QMViewControllersFactory.h"


@interface QMMainTabBarController () <QMNotificationHandlerDelegate>

@property (nonatomic, strong) dispatch_group_t importGroup;

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
    [[QMApi instance].chatService addDelegate:self];
    
    [self customizeTabBar];
    [self.navigationController setNavigationBarHidden:YES animated:NO];

    __weak __typeof(self)weakSelf = self;
    
    [[QMApi instance] autoLogin:^(BOOL success) {
        if (!success) {
            
            [[QMApi instance] logout:^(BOOL logoutSuccess) {
                [weakSelf performSegueWithIdentifier:@"SplashSegue" sender:nil];
            }];
            
        } else {
            
            // subscribe to push notifications
            [[QMApi instance] subscribeToPushNotificationsForceSettings:NO complete:^(BOOL subscribeToPushNotificationsSuccess) {
                
                if (!subscribeToPushNotificationsSuccess) {
                    [QMApi instance].settingsManager.pushNotificationsEnabled = NO;
                }
            }];
            
            [weakSelf loginToChat];
        }
    }];
}

- (void)loginToChat
{
    [[QMApi instance] loginChat:^(BOOL loginSuccess) {

        QBUUser *usr = [QMApi instance].currentUser;
        if (!usr.isImport) {
            self.importGroup = dispatch_group_create();
            dispatch_group_enter(self.importGroup);
            [[QMApi instance] importFriendsFromFacebook:^(BOOL success) {
                //
                dispatch_group_leave(self.importGroup);
            }];
            dispatch_group_enter(self.importGroup);
            [[QMApi instance] importFriendsFromAddressBookWithCompletion:^(BOOL succeded, NSError *error) {
                //
                dispatch_group_leave(self.importGroup);
            }];
        
            dispatch_group_notify(self.importGroup, dispatch_get_main_queue(), ^{
                //
                usr.isImport = YES;
                QBUpdateUserParameters *params = [QBUpdateUserParameters new];
                params.customData = usr.customData;
                [[QMApi instance] updateCurrentUser:params image:nil progress:nil completion:^(BOOL success) {}];
            });
        }
        
        // open chat if app was launched by push notifications
        NSDictionary *push = [[QMApi instance] pushNotification];
        
        if (push != nil) {
            if( push[kPushNotificationDialogIDKey] ){
                [SVProgressHUD show];
                [[QMApi instance] handlePushNotificationWithDelegate:self];
            }
        }
        
        [[QMApi instance] fetchAllDialogs:^{
            [[QMApi instance] joinGroupDialogs];
        }];
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

- (void)showNotificationForMessage:(QBChatMessage *)message inDialogID:(NSString *)dialogID
{
    if ([[QMApi instance].settingsManager.dialogWithIDisActive isEqualToString:dialogID]) return;

    QBChatDialog* dialog = [[QMApi instance].chatService.dialogsMemoryStorage chatDialogWithID:dialogID];
    if (dialog == nil) {
        dialog = message.dialog;
    }
    
    // delayed property working correcrtly for private chat messages only
    if (message.delayed && dialog.type == QBChatDialogTypePrivate) return;
    
    [QMSoundManager playMessageReceivedSound];
    
    __weak __typeof(self)weakSelf = self;
    [QMMessageBarStyleSheetFactory showMessageBarNotificationWithMessage:message chatDialog:dialog completionBlock:^(MPGNotification *notification, NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            if (![[QMApi instance].settingsManager.dialogWithIDisActive isEqualToString:dialogID]) {
                UINavigationController *navigationController = (UINavigationController *)[weakSelf selectedViewController];
                UIViewController *chatController = [QMViewControllersFactory chatControllerWithDialogID:dialogID];
                [navigationController pushViewController:chatController animated:YES];
            }
        }
    }];
}

#pragma mark - QMNotificationHandlerDelegate protocol

- (void)notificationHandlerDidStartLoadingDialogFromServer {
    [SVProgressHUD showWithStatus:@"Loading dialog..." maskType:SVProgressHUDMaskTypeClear];
}

- (void)notificationHandlerDidFinishLoadingDialogFromServer {
    [SVProgressHUD dismiss];
}

- (void)notificationHandlerDidSucceedFetchingDialog:(QBChatDialog *)chatDialog {
    [SVProgressHUD dismiss];
    UINavigationController *navigationController = (UINavigationController *)[self selectedViewController];
    UIViewController *chatController = [QMViewControllersFactory chatControllerWithDialog:chatDialog];
    [navigationController pushViewController:chatController animated:YES];
}

- (void)notificationHandlerDidFailFetchingDialog {
    [SVProgressHUD showErrorWithStatus:@"Dialog was not found"];
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

#pragma mark - QMChatServiceDelegate

- (void)chatService:(QMChatService *)chatService didAddMessageToMemoryStorage:(QBChatMessage *)message forDialogID:(NSString *)dialogID {
    if (message.senderID != self.currentUser.ID) {
        [self showNotificationForMessage:message inDialogID:dialogID];
    }
}


#pragma mark - QMChatConnectionDelegate

- (void)chatServiceChatDidConnect:(QMChatService *)chatService
{
    [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"QM_STR_CHAT_CONNECTED", nil) maskType:SVProgressHUDMaskTypeClear];
}

- (void)chatServiceChatDidReconnect:(QMChatService *)chatService
{
    [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"QM_STR_CHAT_RECONNECTED", nil) maskType:SVProgressHUDMaskTypeClear];
}

- (void)chatServiceChatDidNotLoginWithError:(NSError *)error
{
    if ([[QMApi instance] isInternetConnected]) {
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:NSLocalizedString(@"QM_STR_CHAT_FAILED_TO_CONNECT_WITH_ERROR", nil), error.localizedDescription]];
    }
}

- (void)chatServiceChatDidFailWithStreamError:(NSError *)error
{
    if ([[QMApi instance] isInternetConnected]) {
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:NSLocalizedString(@"QM_STR_CHAT_FAILED_TO_CONNECT_WITH_STREAM_ERROR", nil), error.localizedDescription]];
    }
}

@end
