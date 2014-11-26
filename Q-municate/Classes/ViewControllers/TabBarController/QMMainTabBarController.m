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
#import "QMServicesManager.h"
#import "QMTasks.h"

@interface QMMainTabBarController ()

@end

@implementation QMMainTabBarController

- (void)dealloc {
    NSLog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.chatDelegate = self;
    
    [self customizeTabBar];
    [self.navigationController setNavigationBarHidden:YES
                                             animated:NO];
    [QMTasks taskLogin:^(BOOL loginSuccess) {
        
        if (loginSuccess) {
            
            [QMTasks taskFetchDialogsAndUsers:^(BOOL success) {
                
            }];
        }
    }];
}

//- (void)setChatDelegate:(id)chatDelegate
//{
//    if (chatDelegate == nil) {
//        _chatDelegate = self;
//        return;
//    }
//    _chatDelegate = chatDelegate;
//}

//- (void)subscribeToNotifications
//{
//    __weak typeof(self)weakSelf = self;
//    [[QMChatReceiver instance] chatAfterDidReceiveMessageWithTarget:self block:^(QBChatMessage *message) {
//        if (message.delayed) {
//            return;
//        }
//        QBChatDialog *dialog = [[QMApi instance] chatDialogWithID:message.cParamDialogID];
//        [weakSelf message:message forOtherDialog:dialog];
//    }];
//}

- (void)customizeTabBar {

    self.tabBar.tintColor = [UIColor whiteColor];
    [[UITabBarItem appearance] setTitleTextAttributes:@{
                                                        NSForegroundColorAttributeName : self.tabBar.tintColor
                                                        }
                                             forState:UIControlStateNormal];
    
    [self configureTabBarItemWithIndex:0
                         iconImageName:@"tb_chat"];
    
    [self configureTabBarItemWithIndex:1
                         iconImageName:@"tb_friends"];
    
    [self configureTabBarItemWithIndex:2
                         iconImageName:@"tb_invite"];
    
    [self configureTabBarItemWithIndex:3
                         iconImageName:@"tb_settings"];
    
    for (UINavigationController *navViewController in self.viewControllers ) {
        
        NSAssert([navViewController isKindOfClass:[UINavigationController class]], @"is not UINavigationController");
        [navViewController.viewControllers makeObjectsPerformSelector:@selector(view)];
    }
}

- (void)configureTabBarItemWithIndex:(NSUInteger)index
                       iconImageName:(NSString *)iconImageName {
    
    UIImage *iconImage = [UIImage imageNamed:iconImageName];
    UIImage *iconImageWithRenderingMode =
    [iconImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    UITabBarItem *tabBarItem = self.tabBar.items[index];
    
    tabBarItem.image = iconImageWithRenderingMode;
    tabBarItem.selectedImage = iconImageWithRenderingMode;
}

//#pragma mark - QMChatDataSourceDelegate
//
//- (void)message:(QBChatMessage *)message forOtherDialog:(QBChatDialog *)otherDialog {
//    
//    if (message.cParamNotificationType > 0) {
//        [self.chatDelegate tabBarChatWithChatMessage:message chatDialog:otherDialog showTMessage:NO];
//    }
//    else if ([self.chatDelegate isKindOfClass:QMChatViewController.class] && [otherDialog.ID isEqual:((QMChatViewController *)self.chatDelegate).dialog.ID]) {
//        [self.chatDelegate tabBarChatWithChatMessage:message chatDialog:otherDialog showTMessage:NO];
//    }
//    else {
//        [self.chatDelegate tabBarChatWithChatMessage:message chatDialog:otherDialog showTMessage:YES];
//    }
//}

//#pragma mark - QMTabBarChatDelegate
//
//- (void)tabBarChatWithChatMessage:(QBChatMessage *)message chatDialog:(QBChatDialog *)dialog showTMessage:(BOOL)show
//{
//    if (!show) {
//        return;
//    }
//    [QMSoundManager playMessageReceivedSound];
//    
//    __weak typeof(self) weakSelf = self;
//    [QMMessageBarStyleSheetFactory showMessageBarNotificationWithMessage:message chatDialog:dialog completionBlock:^(MPGNotification *notification, NSInteger buttonIndex) {
//        if (buttonIndex == 1) {
//            UINavigationController *navigationController = (UINavigationController *)[weakSelf selectedViewController];
//            QMChatViewController *chatController = [weakSelf.storyboard instantiateViewControllerWithIdentifier:@"QMChatViewController"];
//            chatController.dialog = dialog;
//            [navigationController pushViewController:chatController animated:YES];
//        }
//    }];
//    
//}

@end
