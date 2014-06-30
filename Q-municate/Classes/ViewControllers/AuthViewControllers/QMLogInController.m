//
//  QMLogInController.m
//  Q-municate
//
//  Created by Igor Alefirenko on 13/02/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMLogInController.h"
#import "QMWelcomeScreenViewController.h"
#import "QMChatService.h"
#import "QMAddressBook.h"
#import "QMAuthService.h"
#import "QMContactList.h"
#import "QMUtilities.h"
#import "QMSettingsManager.h"
#import "REAlertView.h"

@interface QMLogInController ()

@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UISwitch *rememberMeSwitch;

- (IBAction)logIn:(id)sender;
- (IBAction)connectWithFacebook:(id)sender;
- (IBAction)forgotPassword:(id)sender;

@end

@implementation QMLogInController

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
    
    [[QMAuthService shared] authWithFacebookAndCompletionHandler:^(QBUUser *user, BOOL success, NSString *error) {
        if (!success) {
            [self showAlertWithMessage:error actionSuccess:NO];
            return;
        }
        // remember me:
        [self rememberMe:self.rememberMeSwitch.isOn isFacebookSession:YES];
        
        // save me:
        [[QMContactList shared] setMe:user];
        
        // subscribe to push notification:
        [[QMAuthService shared] subscribeToPushNotifications];
        
        if (user.blobID == 0) {
            [[QMAuthService shared] loadFacebookUserPhotoAndUpdateUser:user completion:^(BOOL success) {
                if (!success) {
                    [self showAlertWithMessage:error.description actionSuccess:NO];
                    return;
                }
                [self logInToQuickbloxChatWithUser:user];
            }];
            return;
        }
        [self logInToQuickbloxChatWithUser:user];
    }];
}

- (IBAction)forgotPassword:(id)sender {
    
    // sending to email
//    NSString *email = self.emailField.text;
//    
//
//    
//    if ([email isEqualToString:kEmptyString]) {
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:kMessageString message:nil delegate:self cancelButtonTitle:kAlertButtonTitleOkString otherButtonTitles:nil];
//        alertView.tag = 1;
//        alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
//        [alertView show];
//    }
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

//#pragma mark - Alert

//- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//    if (alertView.tag == 1) {
//        NSString *emailString = [alertView textFieldAtIndex:0].text;
//        if (![emailString isEqualToString:kEmptyString]) {
//            [self resetPasswordForMail:emailString];
//        } else {
//            [self showAlertWithMessage:kMessageString actionSuccess:NO];
//        }
//    } else {
//		self.passwordField.text = kEmptyString;
//	}
//}



- (void)showAlertWithMessage:(NSString *)messageString actionSuccess:(BOOL)success {
    
    [REAlertView presentAlertViewWithConfiguration:^(REAlertView *alertView) {
        alertView.title = success ? kAlertTitleSuccessString : kAlertTitleErrorString;
        alertView.message = messageString;
        [alertView addButtonWithTitle:kAlertButtonTitleOkString andActionBlock:^{}];
    }];
}

//- (void)resetPasswordForMail:(NSString *)emailString
//{
//    [QMUtilities showActivityView];
//    [[QMAuthService shared] resetUserPasswordForEmail:emailString completion:^(Result *result) {
//        if (result.success) {
//            // show alert
//            [self showAlertWithMessage:kAlertBodyMessageWasSentToMailString actionSuccess:YES];
//        } else {
//            NSString *errorMessage = [[result.errors description] stringByReplacingOccurrencesOfString:@"(" withString:@""];
//            errorMessage = [errorMessage stringByReplacingOccurrencesOfString:@")" withString:@""];
//
//            [self showAlertWithMessage:errorMessage actionSuccess:NO];
//        }
//        [QMUtilities hideActivityView];
//    }];
//}


#pragma mark - Options

- (void)logInToQuickbloxChatWithUser:(QBUUser *)user
{
    // login to Quickblox chat:
    [[QMChatService shared] loginWithUser:user completion:^(BOOL success) {
        if (success) {
            [self performSegueWithIdentifier:kTabBarSegueIdnetifier sender:nil];
		}
    }];
}

@end
