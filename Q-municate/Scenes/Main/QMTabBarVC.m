//
//  QMTabBarVC.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 5/17/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMTabBarVC.h"
#import "QMNotification.h"
#import "QMTasks.h"
#import "QMCore.h"
#import "QMChatVC.h"
#import "QMSoundManager.h"

@interface QMTabBarVC ()

<
UITabBarControllerDelegate,

QMPushNotificationManagerDelegate,
QMChatServiceDelegate,
QMChatConnectionDelegate
>

@property (strong, nonatomic) BFTask *autoLoginTask;

@end

@implementation QMTabBarVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // subscribing for delegates
    [[QMCore instance].chatService addDelegate:self];
    self.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.navigationItem.title == nil) {
        
        [self updateNavigationItem:self.selectedViewController.navigationItem];
    }
    
    if (self.autoLoginTask == nil) {
        
        [self performAutoLoginAndFetchData];
    }
}

- (void)performAutoLoginAndFetchData {
    
    [QMNotification showNotificationPanelWithType:QMNotificationPanelTypeLoading message:NSLocalizedString(@"QM_STR_CONNECTING", nil) timeUntilDismiss:0];
    
    @weakify(self);
    self.autoLoginTask = [[QMTasks taskAutoLogin] continueWithBlock:^id _Nullable(BFTask<QBUUser *> * _Nonnull task) {
        @strongify(self);
        
        if (task.isFaulted && (task.error.code == QBResponseStatusCodeUnknown
                               || task.error.code == QBResponseStatusCodeForbidden
                               || task.error.code == QBResponseStatusCodeNotFound
                               || task.error.code == QBResponseStatusCodeUnAuthorized
                               || task.error.code == QBResponseStatusCodeValidationFailed)) {
            [[[QMCore instance] logout] continueWithBlock:^id _Nullable(BFTask * _Nonnull __unused logoutTask) {
                
                [self performSegueWithIdentifier:kQMSceneSegueAuth sender:nil];
                return nil;
            }];
            
            return nil;
        }
        else {
            
            if ([QMCore instance].pushNotificationManager.pushNotification != nil) {
                
                [[QMCore instance].pushNotificationManager handlePushNotificationWithDelegate:self];
            }
            
            return [[QMCore instance].chatService connect];
        }
    }];
}

#pragma mark - Helpers

- (void)updateNavigationItem:(UINavigationItem *)navigationItem {
    
    self.navigationItem.title = navigationItem.title;
    self.navigationItem.titleView = navigationItem.titleView;
    self.navigationItem.prompt = navigationItem.prompt;
    self.navigationItem.leftBarButtonItems = navigationItem.leftBarButtonItems;
    self.navigationItem.rightBarButtonItems = navigationItem.rightBarButtonItems;
    self.navigationItem.backBarButtonItem = navigationItem.backBarButtonItem;
}

#pragma mark - Notification

- (void)showNotificationForMessage:(QBChatMessage *)chatMessage {
    
    if (chatMessage.dialogID == nil) {
        // message missing dialog ID
        NSAssert(nil, @"Message should contain dialog ID.");
        return;
    }
    
    if ([[QMCore instance].activeDialogID isEqualToString:chatMessage.dialogID]) {
        // dialog is already on screen
        return;
    }
    
    QBChatDialog *chatDialog = [[QMCore instance].chatService.dialogsMemoryStorage chatDialogWithID:chatMessage.dialogID];
    
    if (chatMessage.delayed && chatDialog.type == QBChatDialogTypePrivate) {
        // no reason to display private delayed messages
        // group chat messages are always considered delayed
        return;
    }
    
    [QMSoundManager playMessageReceivedSound];
    
    [QMNotification showMessageNotificationWithMessage:chatMessage buttonHandler:^(MPGNotification * __unused notification, NSInteger buttonIndex) {
        
        if (buttonIndex == 1) {
            
            QMChatVC *chatVC = [QMChatVC chatViewControllerWithChatDialog:chatDialog];
            [self.navigationController pushViewController:chatVC animated:YES];
        }
    }];
}

#pragma mark - QMTabBarDelegate

- (void)tabBarController:(UITabBarController *)__unused tabBarController didSelectViewController:(UIViewController *)viewController {
    
    [self updateNavigationItem:viewController.navigationItem];
}

#pragma mark - QMPushNotificationManagerDelegate

- (void)pushNotificationManager:(QMPushNotificationManager *)__unused pushNotificationManager didSucceedFetchingDialog:(QBChatDialog *)chatDialog {
    
    UINavigationController *navigationController = (UINavigationController *)[[UIApplication sharedApplication].windows.firstObject rootViewController];
    
    QMChatVC *chatVC = [QMChatVC chatViewControllerWithChatDialog:chatDialog];
    [navigationController pushViewController:chatVC animated:YES];
}

#pragma mark - QMChatServiceDelegate

- (void)chatService:(QMChatService *)__unused chatService didAddMessageToMemoryStorage:(QBChatMessage *)message forDialogID:(NSString *)__unused dialogID {
    
    if (message.senderID == [QMCore instance].currentProfile.userData.ID) {
        // no need to handle notification for self message
        return;
    }
    
    if (message.messageType == QMMessageTypeContactRequest) {
        
        [[[QMCore instance].usersService getUserWithID:message.senderID] continueWithSuccessBlock:^id _Nullable(BFTask<QBUUser *> * _Nonnull __unused task) {
            
            [self showNotificationForMessage:message];
            
            return nil;
        }];
    }
    else {
        
        [self showNotificationForMessage:message];
    }
}

#pragma mark - QMChatConnectionDelegate

- (void)chatServiceChatDidConnect:(QMChatService *)__unused chatService {
    
    [QMTasks taskFetchAllData];
    
    [QMNotification showNotificationPanelWithType:QMNotificationPanelTypeSuccess message:NSLocalizedString(@"QM_STR_CHAT_CONNECTED", nil) timeUntilDismiss:kQMDefaultNotificationDismissTime];
}

- (void)chatServiceChatDidReconnect:(QMChatService *)__unused chatService {
    
    [QMTasks taskFetchAllData];
    
    [QMNotification showNotificationPanelWithType:QMNotificationPanelTypeSuccess message:NSLocalizedString(@"QM_STR_CHAT_RECONNECTED", nil) timeUntilDismiss:kQMDefaultNotificationDismissTime];
}

- (void)chatService:(QMChatService *)__unused chatService chatDidNotConnectWithError:(NSError *)error {
    
    [QMNotification showNotificationPanelWithType:QMNotificationPanelTypeFailed message:[NSString stringWithFormat:NSLocalizedString(@"QM_STR_CHAT_FAILED_TO_CONNECT_WITH_ERROR", nil), error.localizedDescription] timeUntilDismiss:0];
}

@end
