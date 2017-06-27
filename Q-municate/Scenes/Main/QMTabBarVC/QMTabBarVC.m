//
//  QMTabBarVC.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 5/17/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMTabBarVC.h"
#import "QMNotification.h"
#import "QMCore.h"
#import "QMChatVC.h"
#import "QMSoundManager.h"
#import "QBChatDialog+OpponentID.h"
#import "QMHelpers.h"

@interface QMTabBarVC ()

<
UITabBarControllerDelegate,

QMChatServiceDelegate,
QMChatConnectionDelegate
>

@end

@implementation QMTabBarVC

//MARK: - Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // subscribing for delegates
    [[QMCore instance].chatService addDelegate:self];
    
    for (UIViewController *vc in self.viewControllers) {

        vc.tabBarItem.title = nil;
        vc.tabBarItem.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);
    }
}

- (void)viewWillLayoutSubviews {
    
    CGRect tabFrame = self.tabBar.frame; //self.TabBar is IBOutlet of your TabBar
    tabFrame.size.height = 45;
    tabFrame.origin.y = self.view.frame.size.height - 45;
    self.tabBar.frame = tabFrame;
}

//MARK: - Notification

- (void)showNotificationForMessage:(QBChatMessage *)chatMessage {
    
    if (chatMessage.senderID == [QMCore instance].currentProfile.userData.ID) {
        // no need to handle notification for self message
        return;
    }
    
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
    
    MPGNotificationButtonHandler buttonHandler = nil;
    UIViewController *hvc = nil;
    
    BOOL hasActiveCall = [QMCore instance].callManager.hasActiveCall;
    BOOL isiOS8 = iosMajorVersion() < 9;
    
    if (hasActiveCall
        || isiOS8) {
        
        // using hvc if active call or visible keyboard on ios8 devices
        // due to notification triggering window to be hidden
        hvc = [UIApplication sharedApplication].keyWindow.rootViewController;
    }
    
    if (!hasActiveCall) {
        // not showing reply button in active call
        buttonHandler = ^(MPGNotification * __unused notification, NSInteger buttonIndex) {
            
            if (buttonIndex == 1) {
                
                UINavigationController *navigationController = self.viewControllers.firstObject;
                UIViewController *dialogsVC = navigationController.viewControllers.firstObject;
                [dialogsVC performSegueWithIdentifier:kQMSceneSegueChat sender:chatDialog];
            }
        };
    }
    
    [QMNotification showMessageNotificationWithMessage:chatMessage
                                         buttonHandler:buttonHandler
                                    hostViewController:hvc];
}

//MARK: - QMChatServiceDelegate

- (void)chatService:(QMChatService *)chatService
didAddMessageToMemoryStorage:(QBChatMessage *)message
        forDialogID:(NSString *)dialogID {
    
    if (message.messageType == QMMessageTypeContactRequest) {
        
        QBChatDialog *chatDialog = [chatService.dialogsMemoryStorage chatDialogWithID:dialogID];
        [[[QMCore instance].usersService getUserWithID:[chatDialog opponentID] forceLoad:YES] continueWithSuccessBlock:^id _Nullable(BFTask<QBUUser *> * _Nonnull __unused task) {
            
            [self showNotificationForMessage:message];
            
            return nil;
        }];
    }
    else {
        
        [self showNotificationForMessage:message];
    }
}

@end
