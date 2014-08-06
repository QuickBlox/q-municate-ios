//
//  QMChangePasswordVC.m
//  Qmunicate
//
//  Created by Andrey Ivanov on 24.06.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMChangePasswordVC.h"
#import "QMSettingsManager.h"
#import "QMAuthService.h"
#import "QMUsersService.h"
#import "REAlertView+QMSuccess.h"
#import "UIImage+TintColor.h"
#import "SVProgressHUD.h"
#import "QMApi.h"

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
    NSLog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
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
    
    if (newPassword.length == 0 || confirmOldPassword.length == 0){
        
        [REAlertView showAlertWithMessage:NSLocalizedString(@"QM_STR_FILL_IN_ALL_THE_FIELDS", nil) actionSuccess:NO];
    }
    else if (newPassword.length < kQMMinPasswordLenght) {
        
        [REAlertView showAlertWithMessage:NSLocalizedString(@"QM_STR_PASSWORD_IS_TOO_SHORT", nil) actionSuccess:NO];
    }
    else if (![oldPassword isEqualToString:confirmOldPassword]) {
        
        [REAlertView showAlertWithMessage:NSLocalizedString(@"QM_STR_WRONG_OLD_PASSWORD", nil) actionSuccess:NO];
    }
    else {
        
        [self updatePassword:oldPassword newPassword:newPassword];
    }
}

- (void)updatePassword:(NSString *)oldPassword newPassword:(NSString *)newPassword {

    QBUUser *myProfile = [QMApi instance].currentUser;
    myProfile.password = newPassword;
    myProfile.oldPassword = oldPassword;
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];

    __weak __typeof(self)weakSelf = self;
    [[QMApi instance] changePasswordForCurrentUser:myProfile completion:^(BOOL success) {
        
        if (success) {
            [weakSelf.settingsManager setLogin:myProfile.email andPassword:newPassword];
            
            [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"QM_STR_PASSWORD_CHANGED", nil)];
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }
        
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
