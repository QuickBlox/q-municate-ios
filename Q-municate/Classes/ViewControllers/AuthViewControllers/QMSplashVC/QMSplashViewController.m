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
    ILog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self.splashLogoView setImage:[UIImage imageNamed:IS_HEIGHT_GTE_568 ? @"bg" : @"splash-960"]];
    self.activityIndicator.hidesWhenStopped = YES;
    [self.activityIndicator startAnimating];
    [self createSession];
}

- (void)createSession {
    
    self.reconnectBtn.alpha = 0;
    
    if (!QMApi.instance.isInternetConnected) {
        [REAlertView showAlertWithMessage:NSLocalizedString(@"QM_STR_CHECK_INTERNET_CONNECTION", nil) actionSuccess:NO];
        self.reconnectBtn.alpha = 1;
        return;
    }

    QMSettingsManager *settingsManager = [[QMSettingsManager alloc] init];
    BOOL rememberMe = settingsManager.rememberMe;
    
    if (rememberMe) {
        [self performSegueWithIdentifier:kQMSceneSegueMain sender:nil];
    } else {
        [self performSegueWithIdentifier:kQMSceneSegueAuth sender:nil];
    }

}

- (void)reconnect {
    
    self.reconnectBtn.alpha = 1;
    [self.activityIndicator stopAnimating];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)pressReconnectBtn:(id)sender {
    [self createSession];
}

@end
