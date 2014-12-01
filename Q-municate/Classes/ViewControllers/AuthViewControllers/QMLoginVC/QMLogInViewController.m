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
#import "QMSettingsManager.h"
#import "SVProgressHUD.h"
#import "QMServicesManager.h"

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
    
    [self.navigationController setNavigationBarHidden:NO
                                             animated:YES];
    self.rememberMeSwitch.on = YES;
}

- (void)viewWillAppear:(BOOL)animated {
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
    
    if (email.length > 4 || password.length > 6) {
        
        [REAlertView showAlertWithMessage:NSLocalizedString(@"QM_STR_FILL_IN_ALL_THE_FIELDS", nil)
                            actionSuccess:NO];
    }
    else {
        
        QBUUser *user = [QBUUser user];
        user.email = email;
        user.password = password;
        
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
        
        [QM.authService logInWithUser:user
                           completion:^(QBResponse *response, QBUUser *userProfile)
        {    
             [SVProgressHUD dismiss];
             
             if (response.success) {
                 
                 if (self.rememberMeSwitch.on) {
                     
                     userProfile.password = password;
                     [QM.profile synchronizeWithUserData:userProfile];
                 }
                 
                 [self performSegueWithIdentifier:kTabBarSegueIdnetifier
                                           sender:nil];
             }
         }];
    }
}

- (IBAction)connectWithFacebook:(id)sender {
    
    [QMLicenseAgreement checkAcceptedUserAgreementInViewController:self
                                                        completion:^(BOOL success)
    {
        if (success) {
            
            [QM.authService logInWithFacebookSessionToken:@""
                                               completion:^(QBResponse *response, QBUUser *userProfile)
             {
                 [SVProgressHUD dismiss];
                 
                 if (response.success) {
                     
                     if (self.rememberMeSwitch.on) {
                         [QM.profile synchronizeWithUserData:userProfile];
                     }
                     
                     [self performSegueWithIdentifier:kTabBarSegueIdnetifier
                                               sender:nil];
                 }
				else {

					[REAlertView showAlertWithMessage:NSLocalizedString(@"QM_STR_FACEBOOK_LOGIN_FALED_ALERT_TEXT", nil) actionSuccess:NO];
				}
             }];
        }
    }];
}

@end