//
//  QMForgotPasswordTVC.m
//  Qmunicate
//
//  Created by Andrey Ivanov on 30.06.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMForgotPasswordViewController.h"
#import "SVProgressHUD.h"
#import "REAlertView+QMSuccess.h"
#import "QMCore.h"
#import "QMProfile.h"

@interface QMForgotPasswordViewController ()

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;

@end

@implementation QMForgotPasswordViewController

- (void)dealloc {
    ILog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
}

#pragma mark - actions

- (IBAction)pressResetPasswordBtn:(id)__unused sender {
    
    NSString *email = self.emailTextField.text;
    
    if (email.length > 0) {
        [self resetPasswordForMail:email];
    } else {
        [REAlertView showAlertWithMessage:NSLocalizedString(@"QM_STR_EMAIL_FIELD_IS_EMPTY", nil) actionSuccess:NO];
    }
}

- (void)resetPasswordForMail:(NSString *)emailString {
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];

    @weakify(self);
    [[[QMCore instance].currentProfile resetPasswordForEmail:emailString] continueWithSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
        //
        if (task.isFaulted) {
            [SVProgressHUD dismiss];
            [REAlertView showAlertWithMessage:NSLocalizedString(@"QM_STR_USER_WITH_EMAIL_WASNT_FOUND", nil) actionSuccess:NO];
        } else {
            @strongify(self);
            [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"QM_STR_MESSAGE_WAS_SENT_TO_YOUR_EMAIL", nil)];
            [self.navigationController popViewControllerAnimated:YES];
        }
        return nil;
    }];
}

@end
