//
//  QMLogInVC.m
//  Q-municate
//
//  Created by Igor Alefirenko on 13/02/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMLogInVC.h"
#import "QMWelcomeScreenViewController.h"
#import "QMChatService.h"
#import "QMAuthService.h"
#import "QMContactList.h"
#import "QMSettingsManager.h"
#import "REAlertView+QMSuccess.h"
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
    
    QMSettingsManager *settingsManager = [[QMSettingsManager alloc] init];
    
    self.rememberMeSwitch.on = settingsManager.rememberMe;
    
    if (self.rememberMeSwitch.isOn) {
        [self loadDefaults];
    }
    
    [[QMApi shared].authService startSessionWithBlock:^(QBAAuthSessionCreationResult *result) {
        
        if (result.success) {
            ILog(@"Session created");
        } else {
            [REAlertView showAlertWithMessage:result.errors.lastObject actionSuccess:NO];
        }
    }];
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
        QMContactList *contactList = [QMContactList shared];
        
        [[QMApi shared].authService logInWithEmail:mailString password:passwordString completion:^(QBUUserLogInResult *result) {
            
            if (result.success) {
                // remember me:
                [self rememberMe:self.rememberMeSwitch.isOn isFacebookSession:NO];
                
                result.user.password = passwordString;
                contactList.me = result.user;
                
                // subscribe to push notification:
                [[QMApi shared].authService subscribeToPushNotifications];
                
                // login to chat:
                [self logInToQuickbloxChatWithUser:result.user];
            }
            else {
                [REAlertView showAlertWithMessage:result.errors.lastObject actionSuccess:NO];
            }
        }];
    }
}

- (IBAction)connectWithFacebook:(id)sender {
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [[QMApi shared] loginWithFacebook:^(BOOL success) {
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

#pragma mark - Options

- (void)logInToQuickbloxChatWithUser:(QBUUser *)user {
    // login to Quickblox chat:
    [[QMChatService shared] loginWithUser:user completion:^(BOOL success) {
        if (success) {
            [self performSegueWithIdentifier:kTabBarSegueIdnetifier sender:nil];
		}
    }];
}

@end
