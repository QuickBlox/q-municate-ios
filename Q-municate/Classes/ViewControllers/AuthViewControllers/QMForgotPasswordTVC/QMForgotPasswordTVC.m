//
//  QMForgotPasswordTVC.m
//  Qmunicate
//
//  Created by Andrey on 30.06.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMForgotPasswordTVC.h"
#import "QMApi.h"
#import "SVProgressHUD.h"

@interface QMForgotPasswordTVC ()

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UIButton *resetPasswordBtn;

@end

@implementation QMForgotPasswordTVC

- (void)dealloc {
    NSLog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - actions

- (IBAction)pressResetPasswordBtn:(id)sender {
    
    NSString *email = self.emailTextField.text;
    
    if (email.length > 0) {
        [self resetPasswordForMail:email];
    }
}

- (void)resetPasswordForMail:(NSString *)emailString {
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    @weakify(self)
    [[QMApi instance] resetUserPassordWithEmail:emailString completion:^(BOOL success) {
        @strongify(self)
        if (success) {
            [SVProgressHUD showSuccessWithStatus:kAlertBodyMessageWasSentToMailString];
            [self.navigationController popViewControllerAnimated:YES];
        }else {
            [SVProgressHUD dismiss];
        }
    }];
}

@end
