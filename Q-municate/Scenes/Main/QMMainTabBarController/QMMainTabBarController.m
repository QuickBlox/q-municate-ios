//
//  QMMainTabBarController.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 5/5/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMMainTabBarController.h"
#import "QMNotification.h"
#import "QMTasks.h"
#import "QMCore.h"

#import "QMDialogsViewController.h"
#import "QMSettingsViewController.h"

@interface QMMainTabBarController ()

@property (strong, nonatomic) BFTask *autoLoginTask;

@end

@implementation QMMainTabBarController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // configuring tab bar items
    [self configureTabBarItems];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.autoLoginTask == nil) {
        
        [self performAutoLoginAndFetchData];
    }
}

- (void)configureTabBarItems {
    
    [self addBarItemWithTitle:NSLocalizedString(@"QM_STR_CHATS", nil)
                        image:[UIImage imageNamed:@"qm-tb-chats"]
               viewController:[QMDialogsViewController dialogsViewController]];
    
    [self addBarItemWithTitle:NSLocalizedString(@"QM_STR_SETTINGS", nil)
                        image:[UIImage imageNamed:@"qm-tb-settings"]
               viewController:[QMSettingsViewController settingsViewController]];
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
            
            return [[QMCore instance].chatService connect];
        }
    }];
}

@end
