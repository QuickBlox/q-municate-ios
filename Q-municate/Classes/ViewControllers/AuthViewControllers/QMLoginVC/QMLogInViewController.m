//
//  QMLogInViewController.m
//  Q-municate
//
//  Created by Igor Alefirenko on 13/02/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMLogInViewController.h"
#import "QMCore.h"
#import "QMNotification.h"

@interface QMLogInViewController ()

@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UISwitch *rememberMeSwitch;

@property (weak, nonatomic) BFTask *task;

@end

@implementation QMLogInViewController

- (void)dealloc {
    ILog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

#pragma mark - Actions

- (IBAction)done:(id)__unused sender {
    
    [self.view endEditing:YES];
    
    if (self.task != nil) {
        // task in progress
        return;
    }
    
    if (self.emailField.text.length == 0 || self.passwordField.text.length == 0) {
        
        [QMNotification showNotificationPanelWithType:QMNotificationPanelTypeWarning message:NSLocalizedString(@"QM_STR_FILL_IN_ALL_THE_FIELDS", nil) timeUntilDismiss:kQMDefaultNotificationDismissTime];
    }
    else {
        
        QBUUser *user = [QBUUser user];
        user.email = self.emailField.text;
        user.password = self.passwordField.text;
        
        [QMCore instance].currentProfile.skipSync = !self.rememberMeSwitch.isOn;
        
        [QMNotification showNotificationPanelWithType:QMNotificationPanelTypeLoading message:NSLocalizedString(@"QM_STR_SIGNING_IN", nil) timeUntilDismiss:0];
        
        @weakify(self);
        self.task = [[[QMCore instance].authService loginWithUser:user] continueWithBlock:^id _Nullable(BFTask<QBUUser *> * _Nonnull task) {
            
            @strongify(self);
            if (!task.isFaulted) {
                [QMNotification dismissNotificationPanel];
                
                [self performSegueWithIdentifier:kQMSceneSegueMain sender:nil];
                [[QMCore instance].currentProfile setAccountType:QMAccountTypeEmail];
                [[QMCore instance].currentProfile synchronizeWithUserData:task.result];
            }
            return nil;
        }];
    }
}

@end
