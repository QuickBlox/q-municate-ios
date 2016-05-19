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

#pragma mark - Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self performAutoLoginAndFetchData];
    
    // subscribing for delegates
    [[QMCore instance].chatService addDelegate:self];
}

- (void)performAutoLoginAndFetchData {
    
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

@end
