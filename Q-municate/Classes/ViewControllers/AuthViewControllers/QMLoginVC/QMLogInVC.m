//
//  QMLogInVC.m
//  Q-municate
//
//  Created by Igor Alefirenko on 13/02/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMLogInVC.h"
#import "QMWelcomeScreenViewController.h"
#import "REAlertView+QMSuccess.h"
#import "QMSettingsManager.h"
#import "QMApi.h"
#import "SVProgressHUD.h"

@interface QMLogInVC ()

@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UISwitch *rememberMeSwitch;

- (IBAction)logIn:(id)sender;
- (IBAction)connectWithFacebook:(id)sender;

@end

@implementation QMLogInVC

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    self.rememberMeSwitch.on = [QMApi instance].settingsManager.rememberMe;
    
    if (self.rememberMeSwitch.isOn) {
        [self loadDefaults];
    }
}

- (IBAction)hideKeyboard:(id)sender {
    [sender resignFirstResponder];
}

- (IBAction)logIn:(id)sender {
    
    NSString *mailString = self.emailField.text;
    NSString *passwordString = self.passwordField.text;
    
    if (mailString.length == 0 || passwordString.length == 0) {
        [REAlertView showAlertWithMessage:kAlertBodyFillInAllFieldsString actionSuccess:NO];
    }
    else {

        QBUUser *user = [QBUUser user];
        user.login = mailString;
        user.password = passwordString;
        
        [[QMApi instance] loginWithUser:user completion:^(QBUUserLogInResult *result) {
            [self performSegueWithIdentifier:kTabBarSegueIdnetifier sender:nil];
        }];
    }
}

- (IBAction)connectWithFacebook:(id)sender {
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [[QMApi instance] loginWithFacebook:^(BOOL success) {
        [SVProgressHUD dismiss];
        if (success) {
            [self performSegueWithIdentifier:kTabBarSegueIdnetifier sender:nil];
        }
    }];
}

- (void)rememberMe:(BOOL)isRemember isFacebookSession:(BOOL)isFacebookSession {
    
    QMSettingsManager *settingsManager = [[QMSettingsManager alloc] init];
    
    if (isRemember) {
        
        settingsManager.rememberMe = self.rememberMeSwitch.isOn;
        
        NSString *login = self.emailField.text;
        NSString *password = self.passwordField.text;
        
        if (!isFacebookSession) {
            [settingsManager setLogin:login andPassword:password];
        }
        
    } else {
        [settingsManager clearSettings];
    }
}

- (void)loadDefaults {
    
    QMSettingsManager *settingsManager = [[QMSettingsManager alloc] init];
    
    NSString *login = settingsManager.login;
    NSString *password = settingsManager.password;
    
    self.emailField.text = login;
    self.passwordField.text = password;
}

@end
