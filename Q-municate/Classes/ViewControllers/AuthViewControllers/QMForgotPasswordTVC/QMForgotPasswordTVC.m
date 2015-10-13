//
//  QMForgotPasswordTVC.m
//  Qmunicate
//
//  Created by Andrey Ivanov on 30.06.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMForgotPasswordTVC.h"
#import "QMApi.h"
#import "SVProgressHUD.h"
#import "REAlertView+QMSuccess.h"

@interface QMForgotPasswordTVC ()

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UIButton *resetPasswordBtn;

@end

@implementation QMForgotPasswordTVC

- (void)dealloc {
    ILog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
}

#pragma mark - actions

- (IBAction)pressResetPasswordBtn:(id)sender {
    
    NSString *email = self.emailTextField.text;
    
    if (email.length > 0) {
        [self resetPasswordForMail:email];
    } else {
        [REAlertView showAlertWithMessage:NSLocalizedString(@"QM_STR_EMAIL_FIELD_IS_EMPTY", nil) actionSuccess:NO];
    }
}

- (void)resetPasswordForMail:(NSString *)emailString {
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];

    __weak __typeof(self)weakSelf = self;
    [[QMApi instance] resetUserPassordWithEmail:emailString completion:^(BOOL success) {

        if (success) {
            [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"QM_STR_MESSAGE_WAS_SENT_TO_YOUR_EMAIL", nil)];
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }else {
            [SVProgressHUD dismiss];
            [REAlertView showAlertWithMessage:NSLocalizedString(@"QM_STR_USER_WITH_EMAIL_WASNT_FOUND", nil) actionSuccess:NO];
        }
    }];
}

@end
