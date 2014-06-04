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
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    self.rememberMeSwitch.on = [[[NSUserDefaults standardUserDefaults] objectForKey:kRememberMe] boolValue];
    if (self.rememberMeSwitch.isOn) {
        [self loadDefaults];
    }
    if (![QMAuthService shared].isSessionCreated) {
        [QMUtilities createIndicatorView];
        [[QMAuthService shared] startSessionWithBlock:^(BOOL success, NSError *error) {
            [QMUtilities removeIndicatorView];
            if (success) {
                ILog(@"Session created");
            } else {
                [self showAlertWithMessage:[NSString stringWithFormat:@"%@", error] actionSuccess:NO];
            }
        }];
    }
}

- (IBAction)hideKeyboard:(id)sender
{
    [sender resignFirstResponder];
}


- (IBAction)switchToSignUpController:(id)sender
{
    UINavigationController *navController = [self.root.childViewControllers lastObject];
    [self.root signUpToQuickblox];
    [navController removeFromParentViewController];
}

- (IBAction)logIn:(id)sender
{
    if ([self.emailField.text isEqual:kEmptyString] || [self.passwordField.text isEqual:kEmptyString]) {
        [self showAlertWithMessage:kAlertBodyFillInAllFieldsString actionSuccess:NO];
        return;
    }
    
    [QMUtilities createIndicatorView];
	NSString *mailString = self.emailField.text;
	mailString = [mailString stringByReplacingOccurrencesOfString:@"+" withString:@"%2b"];
    [[QMAuthService shared] logInWithEmail:mailString password:self.passwordField.text completion:^(QBUUser *user, BOOL success, NSError *error) {
        if (!success) {
            ILog(@"error while logging in: %@", error);
            [QMUtilities removeIndicatorView];
            [self showAlertWithMessage:[NSString stringWithFormat:@"%@", error] actionSuccess:NO];
            return;
        }
        // remember me:
        [self rememberMe:self.rememberMeSwitch.isOn];
        
        user.password = self.passwordField.text;
        [QMContactList shared].me = user;
        
        // login to chat:
        [self logInToQuickbloxChatWithUser:user];
    }];
}

- (IBAction)connectWithFacebook:(id)sender
{
    [QMUtilities createIndicatorView];
    [[QMAuthService shared] authWithFacebookAndCompletionHandler:^(QBUUser *user, BOOL success, NSError *error) {
        if (!success) {
            [QMUtilities removeIndicatorView];
            return;
        }
        // save me:
        [[QMContactList shared] setMe:user];
                
        if (user.blobID == 0) {
            [[QMAuthService shared] loadFacebookUserPhotoAndUpdateUser:user completion:^(BOOL success) {
                if (success) {
                    [self logInToQuickbloxChatWithUser:user];
                }
            }];
            return;
        }
        [self logInToQuickbloxChatWithUser:user];
    }];
}

- (IBAction)forgotPassword:(id)sender
{
    // sending to email
    NSString *email = self.emailField.text;
    if ([email isEqualToString:kEmptyString]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:kMessageString message:nil delegate:self cancelButtonTitle:kAlertButtonTitleOkString otherButtonTitles:nil];
        alertView.tag = 1;
        alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
        [alertView show];
    }
}

- (void)rememberMe:(BOOL)isRemember
{
    if (isRemember) {
        [[NSUserDefaults standardUserDefaults] setObject:@(self.rememberMeSwitch.isOn) forKey:kRememberMe];
        [[NSUserDefaults standardUserDefaults] setObject:self.emailField.text forKey:kEmail];
        [[NSUserDefaults standardUserDefaults] setObject:self.passwordField.text forKey:kPassword];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kRememberMe];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kEmail];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kPassword];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)loadDefaults
{
    NSString *email = [[NSUserDefaults standardUserDefaults] objectForKey:kEmail];
    self.emailField.text = email;
    NSString *password = [[NSUserDefaults standardUserDefaults] objectForKey:kPassword];
    self.passwordField.text = password;
}


#pragma mark - Alert

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1) {
        NSString *emailString = [alertView textFieldAtIndex:0].text;
        if (![emailString isEqualToString:kEmptyString]) {
            [self resetPasswordForMail:emailString];
        } else {
            [self showAlertWithMessage:kMessageString actionSuccess:NO];
        }
    } else {
		self.passwordField.text = kEmptyString;
	}
}


- (void)showAlertWithMessage:(NSString *)messageString actionSuccess:(BOOL)success
{
    NSString *title = nil;
    if (success) {
        title = kAlertTitleSuccessString;
    } else {
        title = kAlertTitleErrorString;
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:messageString
                                                   delegate:self
                                          cancelButtonTitle:kAlertButtonTitleOkString
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)resetPasswordForMail:(NSString *)emailString
{
    [QMUtilities createIndicatorView];
    [[QMAuthService shared] resetUserPasswordForEmail:emailString completion:^(Result *result) {
        if (result.success) {
            // show alert
            [self showAlertWithMessage:kAlertBodyMessageWasSentToMailString actionSuccess:YES];
        } else {
            NSString *errorMessage = [[result.errors description] stringByReplacingOccurrencesOfString:@"(" withString:@""];
            errorMessage = [errorMessage stringByReplacingOccurrencesOfString:@")" withString:@""];

            [self showAlertWithMessage:errorMessage actionSuccess:NO];
        }
        [QMUtilities removeIndicatorView];
    }];
}


#pragma mark - Options

- (void)logInToQuickbloxChatWithUser:(QBUUser *)user
{
    // login to Quickblox chat:
    [[QMChatService shared] loginWithUser:user completion:^(BOOL success) {
        [QMUtilities removeIndicatorView];
        if (success) {
            UIWindow *window = (UIWindow *)[[UIApplication sharedApplication].windows firstObject];
            UINavigationController *navigationController = (UINavigationController *)window.rootViewController;
            [navigationController popToRootViewControllerAnimated:NO];
		}
    }];
}

@end
