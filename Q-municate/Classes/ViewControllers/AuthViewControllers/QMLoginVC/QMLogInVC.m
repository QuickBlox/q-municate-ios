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
#import "QMAddressBook.h"
#import "QMAuthService.h"
#import "QMContactList.h"
#import "QMUtilities.h"
#import "QMSettingsManager.h"
#import "REAlertView.h"

@interface QMLogInVC ()

@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UISwitch *rememberMeSwitch;

- (IBAction)logIn:(id)sender;
- (IBAction)connectWithFacebook:(id)sender;

@end

@implementation QMLogInVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    QMSettingsManager *settingsManager = [[QMSettingsManager alloc] init];
    
    self.rememberMeSwitch.on = settingsManager.rememberMe;
    
    if (self.rememberMeSwitch.isOn) {
        [self loadDefaults];
    }
    
    if (![QMAuthService shared].isSessionCreated) {
        
        [[QMAuthService shared] startSessionWithBlock:^(BOOL success, NSString *error) {
            if (success) {
                ILog(@"Session created");
            } else {
                [self showAlertWithMessage:error actionSuccess:NO];
            }
        }];
    }
}

- (IBAction)hideKeyboard:(id)sender {
    [sender resignFirstResponder];
}

- (IBAction)logIn:(id)sender {
    
    if ([self.emailField.text isEqual:kEmptyString] || [self.passwordField.text isEqual:kEmptyString]) {
        [self showAlertWithMessage:kAlertBodyFillInAllFieldsString actionSuccess:NO];
        return;
    }
	
    NSString *mailString = self.emailField.text;
    
    [[QMAuthService shared] logInWithEmail:mailString password:self.passwordField.text completion:^(QBUUser *user, BOOL success, NSString *error) {

        if (!success) {
            [self showAlertWithMessage:error actionSuccess:NO];
            return;
        }
        // remember me:
        [self rememberMe:self.rememberMeSwitch.isOn isFacebookSession:NO];
        
        user.password = self.passwordField.text;
        [QMContactList shared].me = user;
        
        // subscribe to push notification:
        [[QMAuthService shared] subscribeToPushNotifications];
        
        // login to chat:
        [self logInToQuickbloxChatWithUser:user];
    }];
}

- (IBAction)connectWithFacebook:(id)sender {
#warning connetcWithFacebook
//    [[QMAuthService shared] authWithFacebookAndCompletionHandler:^(QBUUser *user, BOOL success, NSString *error) {
//        if (!success) {
//            [self showAlertWithMessage:error actionSuccess:NO];
//            return;
//        }
//        // remember me:
//        [self rememberMe:self.rememberMeSwitch.isOn isFacebookSession:YES];
//        
//        // save me:
//        [[QMContactList shared] setMe:user];
//        
//        // subscribe to push notification:
//        [[QMAuthService shared] subscribeToPushNotifications];
//        
//        if (user.blobID == 0) {
//            [[QMAuthService shared] loadFacebookUserPhotoAndUpdateUser:user completion:^(BOOL success) {
//                if (!success) {
//                    [self showAlertWithMessage:error.description actionSuccess:NO];
//                    return;
//                }
//                [self logInToQuickbloxChatWithUser:user];
//            }];
//            return;
//        }
//        [self logInToQuickbloxChatWithUser:user];
//    }];
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


- (void)showAlertWithMessage:(NSString *)messageString actionSuccess:(BOOL)success {
    
    [REAlertView presentAlertViewWithConfiguration:^(REAlertView *alertView) {
        alertView.title = success ? kAlertTitleSuccessString : kAlertTitleErrorString;
        alertView.message = messageString;
        [alertView addButtonWithTitle:kAlertButtonTitleOkString andActionBlock:^{}];
    }];
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
