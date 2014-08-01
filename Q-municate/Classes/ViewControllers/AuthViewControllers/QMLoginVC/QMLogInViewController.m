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
    
    [[QMApi instance] setAutoLogin:self.rememberMeSwitch.on];
    
    NSString *mail = self.emailField.text;
    NSString *password = self.passwordField.text;
    
    if (mail.length == 0 || password.length == 0) {
        [REAlertView showAlertWithMessage:kAlertBodyFillInAllFieldsString actionSuccess:NO];
    }
    else {

        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
        __weak __typeof(self)weakSelf = self;
        [[QMApi instance] loginWithEmail:mail password:password completion:^(BOOL success) {
            [SVProgressHUD dismiss];
            if (success) {
                [weakSelf performSegueWithIdentifier:kTabBarSegueIdnetifier sender:nil];
            }
            else {
                [weakSelf.rememberMeSwitch setOn:NO animated:YES];
            }
        }];
    }
}

- (IBAction)connectWithFacebook:(id)sender {
    
    BOOL licenceAccepted = [[QMApi instance].settingsManager userAgreementAccepted];
    if (licenceAccepted) {
        [self signInWithFacebook];
        return;
    }
    [self signInWithFacebookAfterAcceptingUserAgreement];
}

- (void)signInWithFacebookAfterAcceptingUserAgreement
{
    [REAlertView presentAlertViewWithConfiguration:^(REAlertView *alertView) {
        alertView.message = @"By clicking Sign Up, you agree to Q-MUNICATE User Agreement.";
        [alertView addButtonWithTitle:kAlertButtonTitleOkString andActionBlock:^{
            [self signInWithFacebook];
            [[QMApi instance].settingsManager setUserAgreementAccepted:YES];
        }];
        [alertView addButtonWithTitle:@"Cancel" andActionBlock:nil];
    }];
}

- (void)signInWithFacebook
{
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    
    __weak __typeof(self)weakSelf = self;
    [[QMApi instance] loginWithFacebook:^(BOOL success) {
        
        [SVProgressHUD dismiss];
        if (success) {
            [weakSelf performSegueWithIdentifier:kTabBarSegueIdnetifier sender:nil];
        }
    }];
}

- (IBAction)changeRememberMe:(UISwitch *)sender {
    [[QMApi instance] setAutoLogin:sender.on];
}

@end
