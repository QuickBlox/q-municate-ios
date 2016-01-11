//
//  QMLogInViewController.m
//  Q-municate
//
//  Created by Igor Alefirenko on 13/02/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMLogInViewController.h"
#import "QMWelcomeScreenViewController.h"
#import "QMLicenseAgreement.h"
#import "REAlertView+QMSuccess.h"
#import "QMApi.h"
#import "SVProgressHUD.h"
#import "QMSettingsManager.h"

@interface QMLogInViewController ()

@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UISwitch *rememberMeSwitch;

@end

@implementation QMLogInViewController

- (void)dealloc {
    ILog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

#pragma mark - Actions

- (IBAction)done:(id)sender {
    
    if (self.emailField.text.length == 0 || self.passwordField.text.length == 0) {
        [REAlertView showAlertWithMessage:NSLocalizedString(@"QM_STR_FILL_IN_ALL_THE_FIELDS", nil) actionSuccess:NO];
    } else {
        
        QBUUser *user = [QBUUser user];
        user.email    = self.emailField.text;
        user.password = self.passwordField.text;
        
        
    }
}

- (IBAction)logIn:(id)sender
{
    if (!QMApi.instance.isInternetConnected) {
        [REAlertView showAlertWithMessage:NSLocalizedString(@"QM_STR_CHECK_INTERNET_CONNECTION", nil) actionSuccess:NO];
        return;
    }
    NSString *email = self.emailField.text;
    NSString *password = self.passwordField.text;
    
    if (email.length == 0 || password.length == 0) {
        [REAlertView showAlertWithMessage:NSLocalizedString(@"QM_STR_FILL_IN_ALL_THE_FIELDS", nil) actionSuccess:NO];
    }
    else {
        
        __weak __typeof(self)weakSelf = self;
        
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
        
        [[QMApi instance] loginWithEmail:email
                                password:password
                              rememberMe:weakSelf.rememberMeSwitch.on
                              completion:^(BOOL success)
         {
             [SVProgressHUD dismiss];
             
             if (success) {
                 [[QMApi instance] setAutoLogin:weakSelf.rememberMeSwitch.on
                                withAccountType:QMAccountTypeEmail];
                 [weakSelf performSegueWithIdentifier:kQMSceneSegueMain
                                               sender:nil];
             }
         }];
    }
}

@end
