//
//  QMSplashViewController.m
//  Q-municate
//
//  Created by lysenko.mykhayl on 3/24/14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMSplashViewController.h"
#import "QMWelcomeScreenViewController.h"
#import "QMAuthService.h"
#import "QMChatService.h"
#import "QMContactList.h"
#import "QMUtilities.h"
#import "QMSettingsManager.h"
#import "REAlertView.h"
#import "QMFacebookService.h"

#warning [QMUtilities shared];

@interface QMSplashViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *splashLogoView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation QMSplashViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.splashLogoView setImage:[UIImage imageNamed:IS_HEIGHT_GTE_568 ? @"splash" : @"splash-960"]];
    [self.activityIndicator startAnimating];
    
    [self initialize];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)initialize {
    
    QMSettingsManager *settingsManager = [[QMSettingsManager alloc] init];
    
    [[QMAuthService shared] startSessionWithBlock:^(QBAAuthSessionCreationResult *result) {
        
        if (result.success) {
            
            BOOL rememberMe = settingsManager.rememberMe;
            
            if (rememberMe) {
                
                NSString *email = settingsManager.login;
                NSString *password = settingsManager.password;
                
                // if user with email was remebered:
                if (email && password) {
                    [self loginWithEmail:email password:password];
                } else {
                    [self loginWithFacebook];
                }
            } else {
                [self performSegueWithIdentifier:kWelcomeScreenSegueIdentifier sender:nil];
            }
            
        } else {
            
            [self showAlertWithMessage:result.errors.lastObject actionSuccess:NO];
        }
    }];

}

- (void)loginWithEmail:(NSString *)email password:(NSString *)password {

    QMContactList *contactList = [QMContactList shared];
    QMAuthService *authService = [QMAuthService shared];
    
    [authService logInWithEmail:email password:password completion:^(QBUUserLogInResult *result) {
        
        if (result.success) {
            
            contactList.me = result.user;
            [self loginWithUser:result.user];
            
        } else {
            [self showAlertWithMessage:result.errors.lastObject actionSuccess:NO];
        }
    }];
}

- (void)loginWithFacebook {
    
    QMAuthService *authService = [QMAuthService shared];
    QMFacebookService *fbService = [[QMFacebookService alloc] init];
    
    [fbService connectToFacebook:^(NSString *sessionToken) {
       
        [authService logInWithFacebookAccessToken:sessionToken completion:^(QBUUserLogInResult *result) {
            
            if (result.success) {
                [self loginWithUser:result.user];
            } else {
                [self showAlertWithMessage:result.errors.lastObject actionSuccess:NO];
            }
        }]; 
    }];
}

- (void)loginWithUser:(QBUUser *)user {
    
    [[QMAuthService shared] subscribeToPushNotifications];
    [[QMChatService shared] loginWithUser:user completion:^(BOOL success) {
        if (success) {
            [self.activityIndicator stopAnimating];
            [self performSegueWithIdentifier:kTabBarSegueIdnetifier sender:nil];
        }
    }];
}

#pragma mark - Alert

- (void)showAlertWithMessage:(NSString *)messageString actionSuccess:(BOOL)success {
    
    [REAlertView presentAlertViewWithConfiguration:^(REAlertView *alertView) {
        alertView.title = success ? kAlertTitleSuccessString : kAlertTitleErrorString;
        alertView.message = messageString;
        [alertView addButtonWithTitle:kAlertButtonTitleOkString andActionBlock:^{}];
    }];
}

@end
