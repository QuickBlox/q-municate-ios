//
//  QMSplashViewController.m
//  Q-municate
//
//  Created by lysenko.mykhayl on 3/24/14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMSplashViewController.h"
#import "QMWelcomeScreenViewController.h"
#import "QMSettingsManager.h"
#import "REAlertView+QMSuccess.h"
#import "QMApi.h"

@interface QMSplashViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *splashLogoView;
@property (weak, nonatomic) IBOutlet UIButton *reconnectBtn;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation QMSplashViewController

- (void)dealloc {
    NSLog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.splashLogoView setImage:[UIImage imageNamed:IS_HEIGHT_GTE_568 ? @"splash" : @"splash-960"]];
    self.reconnectBtn.alpha = 0;

    [self start];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)pressReconnectBtn:(id)sender {

    [UIView animateWithDuration:0.3 animations:^{
        self.reconnectBtn.alpha = 0;
    } completion:^(BOOL finished) {
        [self start];
    }];
}

- (void)needReconnect {
    
    [self.activityIndicator stopAnimating];
    [UIView animateWithDuration:0.3 animations:^{
        self.reconnectBtn.alpha = 1;
    }];
}

- (void)start {
    
    [self.activityIndicator startAnimating];
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

    __weak __typeof(self)weakSelf = self;
    [[QMApi instance] loginWithUser:user completion:^(BOOL success) {
        
        if (success) {
            [weakSelf performSegueWithIdentifier:kTabBarSegueIdnetifier sender:nil];
        }
        else {
            [weakSelf needReconnect];
        }
    }];
}

- (void)loginWithFacebook {
    
    __weak __typeof(self)weakSelf = self;
    [[QMApi instance] loginWithFacebook:^(BOOL success) {
        if (success) {
            [weakSelf performSegueWithIdentifier:kTabBarSegueIdnetifier sender:nil];
        }
        else {
            [weakSelf needReconnect];
        }
    }];
}

@end
