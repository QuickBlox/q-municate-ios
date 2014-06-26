//
//  QMChangePasswordVC.m
//  Qmunicate
//
//  Created by Andrey on 24.06.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMChangePasswordVC.h"
#import "QMSettingsManager.h"
#import "QMAuthService.h"
#import "QMContactList.h"
#import "REAlertView.h"
#import "UIImage+TintColor.h"
#import "SVProgressHUD.h"

const NSUInteger kQMMinPasswordLenght = 7;

@interface QMChangePasswordVC ()

<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *oldPasswordTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *changeButton;
@property (strong, nonatomic) QMSettingsManager *settingsManager;

@end

@implementation QMChangePasswordVC

- (void)dealloc {
    NSLog(@"");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.settingsManager = [[QMSettingsManager alloc] init];
    
    [self configureChangePasswordVC];
}

- (void)configureChangePasswordVC {

    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    UIImage *buttonBG = [UIImage imageNamed:@"blue_conter"];
    UIColor *normalColor = [UIColor colorWithRed:0.091 green:0.674 blue:0.174 alpha:1.000];
    UIEdgeInsets imgInsets = UIEdgeInsetsMake(9, 9, 9, 9);
    [self.changeButton setBackgroundImage:[buttonBG tintImageWithColor:normalColor resizableImageWithCapInsets:imgInsets]
                                 forState:UIControlStateNormal];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.oldPasswordTextField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - actions

- (IBAction)pressChangeButton:(id)sender {
    
    NSString *oldPassword = self.settingsManager.password;
    
    NSString *confirmOldPassword = self.oldPasswordTextField.text;
    NSString *newPassword = self.passwordTextField.text;
    
    if (![oldPassword isEqualToString:confirmOldPassword]) {
        [self showErrorAlertWithMessage:kAlertBodyPasswDoesNotMatchString];
    } else if (newPassword.length < kQMMinPasswordLenght) {
        [self showErrorAlertWithMessage:kAlertBodyPasswordIsShortString];
    } else{
        [self updatePassword:oldPassword newPassword:newPassword];
    }
}

- (void)updatePassword:(NSString *)oldPassword newPassword:(NSString *)newPassword {
    
    QBUUser *myProfile = [QMContactList shared].me;
    myProfile.password = newPassword;
    myProfile.oldPassword = oldPassword;
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    
    [[QMAuthService shared] updateUser:myProfile withCompletion:^(QBUUser *user, BOOL success, NSString *error) {
        if (success) {
            
            [self.settingsManager setLogin:myProfile.login andPassword:myProfile.password];
            [SVProgressHUD showSuccessWithStatus:kAlertBodyPasswordChangedString];
            [self.navigationController popViewControllerAnimated:YES];
            
        } else{
            [SVProgressHUD showErrorWithStatus:@"Error"];
        }
    }];
}

- (void)showErrorAlertWithMessage:(NSString *)message {
    
    [REAlertView presentAlertViewWithConfiguration:^(REAlertView *alertView) {
        alertView.title =  kAlertTitleErrorString;
        alertView.message = message;
        [alertView addButtonWithTitle:kAlertButtonTitleOkString andActionBlock:^{}];
    }];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (textField == self.oldPasswordTextField) {
        [self.passwordTextField becomeFirstResponder];
    } else if (textField == self.passwordTextField) {
        [self pressChangeButton:nil];
    }
    
    return YES;
}

@end
