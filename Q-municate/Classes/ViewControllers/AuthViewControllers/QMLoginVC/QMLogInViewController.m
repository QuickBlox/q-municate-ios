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
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

#pragma mark - Actions

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
        user.email = mailString;
        user.password = passwordString;

        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
        __weak __typeof(self)weakSelf = self;
        [[QMApi instance] loginWithUser:user completion:^(QBUUserLogInResult *result) {
            [SVProgressHUD dismiss];
            [weakSelf performSegueWithIdentifier:kTabBarSegueIdnetifier sender:nil];
        }];
    }
}

- (IBAction)connectWithFacebook:(id)sender {
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];

    __weak __typeof(self)weakSelf = self;
    [[QMApi instance] loginWithFacebook:^(BOOL success) {
        if (success) {
            [weakSelf performSegueWithIdentifier:kTabBarSegueIdnetifier sender:nil];
            [SVProgressHUD dismiss];
        }
    }];
}

- (IBAction)changeRememberMe:(UISwitch *)sender {
    [[QMApi instance] setAutoLogin:sender.isOn];
}

@end
