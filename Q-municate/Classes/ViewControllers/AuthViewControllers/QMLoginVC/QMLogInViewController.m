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
#import "QMSettingsManager.h"
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
    ILog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.rememberMeSwitch.on = YES;
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

- (IBAction)logIn:(id)sender
{
    NSString *email = self.emailField.text;
    NSString *password = self.passwordField.text;
    
    if (email.length == 0 || password.length == 0) {
        [REAlertView showAlertWithMessage:NSLocalizedString(@"QM_STR_FILL_IN_ALL_THE_FIELDS", nil)
                            actionSuccess:NO];
    }
    else {
        
        __weak __typeof(self)weakSelf = self;
        [QMLicenseAgreement checkAcceptedUserAgreementInViewController:self completion:^(BOOL userAgreementSuccess) {
            
            if (userAgreementSuccess) {
                
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
                         [weakSelf performSegueWithIdentifier:kTabBarSegueIdnetifier
                                                       sender:nil];
                     }
                 }];
            }
        }];
    }
}

- (IBAction)connectWithFacebook:(id)sender
{
    __weak __typeof(self)weakSelf = self;
    [QMLicenseAgreement checkAcceptedUserAgreementInViewController:self completion:^(BOOL success) {
        if (success) {
            [weakSelf fireConnectWithFacebook];
        }
    }];
}

- (void)fireConnectWithFacebook
{
    __weak __typeof(self)weakSelf = self;
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [[QMApi instance] singUpAndLoginWithFacebook:^(BOOL success) {
        
        [SVProgressHUD dismiss];
        if (success) {
            [weakSelf performSegueWithIdentifier:kTabBarSegueIdnetifier sender:nil];
        }
    }];
}

@end
