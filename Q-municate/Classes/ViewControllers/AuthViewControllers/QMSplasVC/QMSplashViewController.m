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
#import "QMUsersService.h"
#import "QMincomingCallService.h"
#import "QMSettingsManager.h"
#import "REAlertView+QMSuccess.h"
#import "QMFacebookService.h"
#import "QMApi.h"

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
}

- (void)loginWithEmail:(NSString *)email password:(NSString *)password {
    
    QBUUser *user = [QBUUser user];
    user.email = email;
    user.password = password;
    
    [[QMApi instance] loginWithUser:user completion:^(QBUUserLogInResult *result) {
        [self.activityIndicator stopAnimating];
        [self performSegueWithIdentifier:kTabBarSegueIdnetifier sender:nil];
    }];
}

- (void)loginWithFacebook {
    
    [[QMApi instance] loginWithFacebook:^(BOOL success) {
        if (success) {
            [self.activityIndicator stopAnimating];
            [self performSegueWithIdentifier:kTabBarSegueIdnetifier sender:nil];
        }
    }];
}

@end
