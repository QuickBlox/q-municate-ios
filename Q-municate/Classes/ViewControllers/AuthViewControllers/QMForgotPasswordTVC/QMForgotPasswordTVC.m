//
//  QMForgotPasswordTVC.m
//  Qmunicate
//
//  Created by Andrey on 30.06.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMForgotPasswordTVC.h"
#import "QMAuthService.h"
#import "REAlertView.h"

@interface QMForgotPasswordTVC ()

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UIButton *resetPasswordBtn;

@end

@implementation QMForgotPasswordTVC

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
    
    [[QMAuthService shared] resetUserPasswordForEmail:emailString completion:^(Result *result) {
        if (result.success) {
            
            [self showAlertWithMessage:kAlertBodyMessageWasSentToMailString actionSuccess:YES successBlock:^{
                
            }];
            
        } else {
            NSString *errorMessage = [[result.errors description] stringByReplacingOccurrencesOfString:@"(" withString:@""];
            errorMessage = [errorMessage stringByReplacingOccurrencesOfString:@")" withString:@""];

            [self showAlertWithMessage:errorMessage actionSuccess:NO successBlock:nil];
        }

    }];
}

- (void)showAlertWithMessage:(NSString *)messageString actionSuccess:(BOOL)success successBlock:(void(^)(void))successBlock{
    
    [REAlertView presentAlertViewWithConfiguration:^(REAlertView *alertView) {
        alertView.title = success ? kAlertTitleSuccessString : kAlertTitleErrorString;
        alertView.message = messageString;
        [alertView addButtonWithTitle:kAlertButtonTitleOkString andActionBlock:successBlock];
    }];
}

@end
