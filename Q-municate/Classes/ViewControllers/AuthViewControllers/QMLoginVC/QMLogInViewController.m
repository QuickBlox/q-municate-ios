//
//  QMLogInViewController.m
//  Q-municate
//
//  Created by Igor Alefirenko on 13/02/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMLogInViewController.h"
#import "QMWelcomeScreenViewController.h"
#import "REAlertView+QMSuccess.h"
#import "QMApi.h"
#import "QMSettingsManager.h"
#import "SVProgressHUD.h"

@interface QMLogInViewController ()

@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UISwitch *rememberMeSwitch;
@property (strong, nonatomic) QMSettingsManager *settingsManager;

@end

@implementation QMLogInViewController

- (void)dealloc {
    NSLog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.rememberMeSwitch.on = YES;
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

#pragma mark - Actions

- (IBAction)hideKeyboard:(id)sender {
    [sender resignFirstResponder];
}

- (IBAction)logIn:(id)sender {
    
    
    NSString *email = self.emailField.text;
    NSString *password = self.passwordField.text;
    
    if (email.length == 0 || password.length == 0) {
        [REAlertView showAlertWithMessage:kAlertBodyFillInAllFieldsString actionSuccess:NO];
    }
    else {

        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
        __weak __typeof(self)weakSelf = self;

        [[QMApi instance] loginWithEmail:email password:password rememberMe:weakSelf.rememberMeSwitch.on completion:^(BOOL success) {
            [SVProgressHUD dismiss];
            if (success) {
                [[QMApi instance] setAutoLogin:weakSelf.rememberMeSwitch.on withAccountType:QMAccountTypeEmail];
                [weakSelf performSegueWithIdentifier:kTabBarSegueIdnetifier sender:nil];
            }
        }];
    }
}

- (IBAction)connectWithFacebook:(id)sender {
    
    __weak __typeof(self)weakSelf = self;
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [[QMApi instance] singUpAndLoginWithFacebook:^(BOOL success) {
        
        [SVProgressHUD dismiss];
        if (success) {
            [weakSelf performSegueWithIdentifier:kTabBarSegueIdnetifier sender:nil];
        }
    }];
}

- (void)signInWithFacebookAfterAcceptingUserAgreement {
    
    [REAlertView presentAlertViewWithConfiguration:^(REAlertView *alertView) {
        alertView.message = @"By clicking Sign Up, you agree to Q-MUNICATE User Agreement.";
        [alertView addButtonWithTitle:kAlertButtonTitleOkString andActionBlock:^{
            [[QMApi instance].settingsManager setUserAgreementAccepted:YES];
        }];
        [alertView addButtonWithTitle:@"Cancel" andActionBlock:nil];
    }];
}


@end
