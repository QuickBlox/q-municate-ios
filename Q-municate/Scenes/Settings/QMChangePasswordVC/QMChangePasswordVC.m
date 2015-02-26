//
//  QMChangePasswordVC.m
//  Q-municate
//
//  Created by Andrey Ivanov on 24.06.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMChangePasswordVC.h"
#import "REAlertView+QMSuccess.h"
#import "UIImage+TintColor.h"
#import "SVProgressHUD.h"
#import "QMServicesManager.h"

const NSUInteger kQMMinPasswordLenght = 7;

@interface QMChangePasswordVC ()

<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *oldPasswordTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *changeButton;

@end

@implementation QMChangePasswordVC

- (void)dealloc {
    ILog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.changeButton.layer.cornerRadius = 5.0f;
    
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
    
    NSString *oldPassword = nil;//self.settingsManager.password;
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
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    
    __weak __typeof(self)weakSelf = self;
    [QM.profile changePassword:newPassword completion:^(BOOL success) {
        
        if (success) {
            
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
