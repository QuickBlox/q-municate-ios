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
    
    if (![[QBChat instance] isConnected]) {
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
            
            [[QMApi instance] logoutWithCompletion:^(BOOL succeed) {
                //
                [weakSelf performSegueWithIdentifier:kQMSceneSegueStart sender:nil];
            }];
            
        } else {
            
            // subscribe to push notifications
            [[QMApi instance] subscribeToPushNotificationsForceSettings:NO complete:^(BOOL subscribeToPushNotificationsSuccess) {
                
                if (!subscribeToPushNotificationsSuccess) {
                    [QMApi instance].settingsManager.pushNotificationsEnabled = NO;
                }
            }];
            
            [weakSelf connectToChat];
        }
    }];
}

- (void)connectToChat
{
    [[QMApi instance] connectChat:^(BOOL loginSuccess) {
        
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
        
        [[QMApi instance] fetchAllData:nil];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)customizeTabBar {
    
    UIColor *white = [UIColor whiteColor];
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : white} forState:UIControlStateNormal];
    
    // selection image:
    UIImage *tabSelectionImage = nil;
    if ([QMDevice isIphone6] || [QMDevice isIphone6Plus]) {
        tabSelectionImage = [UIImage imageNamed:@"iphone6_tab_fone"];
    } else {
        tabSelectionImage = [UIImage imageNamed:@"tab_fone"];
    }
    self.tabBar.selectionIndicatorImage = tabSelectionImage;
    
    for (UINavigationController *navViewController in self.viewControllers ) {
//        NSAssert([navViewController isKindOfClass:[UINavigationController class]], @"is not UINavigationController");
//        [navViewController.viewControllers makeObjectsPerformSelector:@selector(view)];
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
    [[QMApi instance] showMessageBarNotificationWithMessage:message chatDialog:dialog completionBlock:^(MPGNotification *notification, NSInteger buttonIndex) {
        
        if (buttonIndex == 1) {
            if (![[QMApi instance].settingsManager.dialogWithIDisActive isEqualToString:dialogID]) {
                UINavigationController *navigationController = (UINavigationController *)[weakSelf selectedViewController];
                UIViewController *chatController = [QMViewControllersFactory chatControllerWithDialogID:dialogID];
                [navigationController pushViewController:chatController animated:YES];
            }
        }
    }];
}

- (void)getUsersIfNeeded:(NSArray *)users andShowNotificationForMessage:(QBChatMessage *)message {
    __weak __typeof(self)weakSelf = self;
    [[[QMApi instance].usersService getUsersWithIDs:users] continueWithBlock:^id(BFTask<NSArray<QBUUser *> *> *task) {
        //
        [weakSelf showNotificationForMessage:message inDialogID:message.dialogID];
        return nil;
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

#pragma mark - QMChatServiceDelegate

- (void)chatService:(QMChatService *)chatService didAddMessageToMemoryStorage:(QBChatMessage *)message forDialogID:(NSString *)dialogID {
    if (message.senderID != self.currentUser.ID) {
        
        if (message.messageType == QMMessageTypeContactRequest) {
            // download user for contact request if needed
            [self getUsersIfNeeded:@[@(message.senderID)] andShowNotificationForMessage:message];
        } else if (message.dialogUpdateType == QMDialogUpdateTypeOccupants && message.addedOccupantsIDs.count > 0) {
            // download users for added occupants if needed
            [self getUsersIfNeeded:message.addedOccupantsIDs andShowNotificationForMessage:message];
        } else {
            
            [self showNotificationForMessage:message inDialogID:dialogID];
        }
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

- (void)chatService:(QMChatService *)chatService chatDidNotConnectWithError:(NSError *)error
{
    if ([[QMApi instance] isInternetConnected]) {
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:NSLocalizedString(@"QM_STR_CHAT_FAILED_TO_CONNECT_WITH_ERROR", nil), error.localizedDescription]];
    }
}

@end
