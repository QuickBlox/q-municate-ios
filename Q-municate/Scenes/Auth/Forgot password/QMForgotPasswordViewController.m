//
//  QMForgotPasswordTVC.m
//  Qmunicate
//
//  Created by Andrey Ivanov on 30.06.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMForgotPasswordViewController.h"
#import "QMTasks.h"
#import "QMNavigationController.h"

@interface QMForgotPasswordViewController ()

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;

@property (weak, nonatomic) BFTask *task;

@end

@implementation QMForgotPasswordViewController

- (void)dealloc {
    QMSLog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.emailTextField becomeFirstResponder];
}

//MARK: - actions

- (IBAction)pressResetPasswordBtn:(id)__unused sender {
    
    if (self.task != nil) {
        // task in progress
        return;
    }
    
    NSString *email = self.emailTextField.text;
    
    if (email.length > 0) {
        
        [self resetPasswordForMail:email];
    }
    else {
        
        [(QMNavigationController *)self.navigationController showNotificationWithType:QMNotificationPanelTypeWarning message:NSLocalizedString(@"QM_STR_EMAIL_FIELD_IS_EMPTY", nil) duration:kQMDefaultNotificationDismissTime];
    }
}

- (void)resetPasswordForMail:(NSString *)emailString {
    
    [(QMNavigationController *)self.navigationController showNotificationWithType:QMNotificationPanelTypeLoading
                                                                          message:NSLocalizedString(@"QM_STR_LOADING", nil)
                                                                         duration:0];
    
    __weak UINavigationController *navigationController = self.navigationController;
    
    @weakify(self);
    self.task = [[QMTasks taskResetPasswordForEmail:emailString] continueWithBlock:^id _Nullable(BFTask * _Nonnull task) {
        
        @strongify(self);
        if (task.isFaulted) {
            
            [(QMNavigationController *)navigationController showNotificationWithType:QMNotificationPanelTypeFailed message:NSLocalizedString(@"QM_STR_USER_WITH_EMAIL_WASNT_FOUND", nil) duration:kQMDefaultNotificationDismissTime];
        }
        else {
            
            [(QMNavigationController *)navigationController showNotificationWithType:QMNotificationPanelTypeSuccess message:NSLocalizedString(@"QM_STR_MESSAGE_WAS_SENT_TO_YOUR_EMAIL", nil) duration:kQMDefaultNotificationDismissTime];
            [self.navigationController popViewControllerAnimated:YES];
        }
        
        return nil;
    }];
}

@end
