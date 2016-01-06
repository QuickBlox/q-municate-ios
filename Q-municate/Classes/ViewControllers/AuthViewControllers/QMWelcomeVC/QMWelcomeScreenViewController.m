//
//  SplashControllerViewController.m
//  Q-municate
//
//  Created by Igor Alefirenko on 13/02/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMWelcomeScreenViewController.h"
#import "QMLicenseAgreement.h"
#import "QMSplashViewController.h"
#import "QMApi.h"
#import "QMSettingsManager.h"
#import "SVProgressHUD.h"
#import "REAlertView.h"
#import "REAlertView+QMSuccess.h"

@interface QMWelcomeScreenViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *bubleImage;

- (IBAction)connectWithFacebook:(id)sender;

@end

@implementation QMWelcomeScreenViewController

- (void)dealloc {
    ILog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.bubleImage.image = [UIImage imageNamed:IS_HEIGHT_GTE_568 ? @"logo_big" : @"logo_big_960"];
    [[QMApi instance].settingsManager defaultSettings];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

#pragma mark - Actions

- (IBAction)connectWithFacebook:(id)sender
{
    if (!QMApi.instance.isInternetConnected) {
        [REAlertView showAlertWithMessage:NSLocalizedString(@"QM_STR_CHECK_INTERNET_CONNECTION", nil) actionSuccess:NO];
        return;
    }
    __weak __typeof(self)weakSelf = self;
    [QMLicenseAgreement checkAcceptedUserAgreementInViewController:self completion:^(BOOL success) {
        if (success) {
            [weakSelf signInWithFacebook];
        }
    }];
}

- (void)signInWithFacebook {

    __weak __typeof(self)weakSelf = self;
    [[QMApi instance] singUpAndLoginWithFacebook:^(BOOL success) {

        if (success) {
            [weakSelf performSegueWithIdentifier:kQMSceneSegueMain sender:nil];
        } else {
            [REAlertView showAlertWithMessage:NSLocalizedString(@"QM_STR_FACEBOOK_LOGIN_FALED_ALERT_TEXT", nil) actionSuccess:NO];
        }
    }];
}

@end
