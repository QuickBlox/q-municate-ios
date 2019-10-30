//
//  QMTabBarVC.m
//  Q-municate
//
//  Created by Injoit on 5/17/16.
//  Copyright © 2016 QuickBlox. All rights reserved.
//

#import "QMTabBarVC.h"
#import "QMNotification.h"
#import "QMCore.h"
#import "QMChatVC.h"
#import "QMSoundManager.h"
#import "QBChatDialog+OpponentID.h"
#import "QMHelpers.h"
#import <UIDevice_Hardware/UIDevice-Hardware.h>

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
    [QMCore.instance.chatService addDelegate:self];
    
    for (UIViewController *vc in self.viewControllers) {
        
        vc.tabBarItem.title = nil;
        vc.tabBarItem.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            CGSize screenSize = [[UIScreen mainScreen] bounds].size;
            if (screenSize.height == 812.0f)
                vc.tabBarItem.imageInsets = UIEdgeInsetsMake(5, 0, -25, 0);
            
        }
    }
}

- (void)fixTabBar {
    if ([self.selectedViewController isKindOfClass:[UINavigationController class]]) {
        
        UINavigationController *navVC = self.selectedViewController;
        
        if (navVC.viewControllers.lastObject.hidesBottomBarWhenPushed) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tabBar setHidden:YES];
            });
        }
    }
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    [self fixTabBar];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    [self fixTabBar];
    
    if (![UIDevice.currentDevice.modelName isEqualToString:@"iPhone X"]) {
        //Simulator
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            CGSize screenSize = [[UIScreen mainScreen] bounds].size;
            if (screenSize.height == 812.0f) {
                
                return;
            }
        }
        
        CGRect tabFrame = self.tabBar.frame; //self.TabBar is IBOutlet of your TabBar
        tabFrame.size.height = 45;
        tabFrame.origin.y = self.view.frame.size.height - 45;
        self.tabBar.frame = tabFrame;
    }
}

//MARK: - Notification

- (void)showNotificationForMessage:(QBChatMessage *)chatMessage {
    
    if (UIApplication.sharedApplication.applicationState == UIApplicationStateBackground ||
        UIApplication.sharedApplication.applicationState == UIApplicationStateInactive) {
        // no need to show notification s if app is active in background
        // e.g. call kit
        return;
    }
    
    if (chatMessage.senderID == QMCore.instance.currentProfile.userData.ID) {
        // no need to handle notification for self message
        return;
    }
    
    if (chatMessage.dialogID == nil) {
        // message missing dialog ID
        NSAssert(nil, @"Message should contain dialog ID.");
        return;
    }
    
    if ([QMCore.instance.activeDialogID isEqualToString:chatMessage.dialogID]) {
        // dialog is already on screen
        return;
    }
    
    QBChatDialog *chatDialog = [QMCore.instance.chatService.dialogsMemoryStorage chatDialogWithID:chatMessage.dialogID];
    
    if (chatMessage.delayed && chatDialog.type == QBChatDialogTypePrivate) {
        // no reason to display private delayed messages
        // group chat messages are always considered delayed
        return;
    }
    
    BOOL hasActiveCall = QMCore.instance.callManager.hasActiveCall;
    if (hasActiveCall
        && chatMessage.isCallNotificationMessage) {
        // do not show call notification message if there is an active call
        return;
    }
    
    [QMSoundManager playMessageReceivedSound];
    
    MPGNotificationButtonHandler buttonHandler = nil;
    UIViewController *hvc = nil;
    
    BOOL isiOS8 = iosMajorVersion() < 9;
    if (hasActiveCall || isiOS8) {
        // using hvc if active call or visible keyboard on ios8 devices
        // due to notification triggering window to be hidden
        hvc = UIApplication.sharedApplication.keyWindow.rootViewController;
    }
    
    if (!hasActiveCall) {
        // not showing reply button in active call
        buttonHandler = ^(MPGNotification *  notification, NSInteger buttonIndex) {
            
            if (buttonIndex == 1) {
                
                [UIApplication.sharedApplication sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
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
        [[[QMCore instance].usersService getUserWithID:[chatDialog opponentID] forceLoad:YES]
         continueWithSuccessBlock:^id _Nullable(BFTask<QBUUser *> * _Nonnull  task) {
             
             [self showNotificationForMessage:message];
             
             return nil;
         }];
    }
    else {
        
        [self showNotificationForMessage:message];
    }
}

@end
