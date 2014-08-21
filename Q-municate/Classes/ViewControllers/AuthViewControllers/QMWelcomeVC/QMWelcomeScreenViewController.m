//
//  SplashControllerViewController.m
//  Q-municate
//
//  Created by Igor Alefirenko on 13/02/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMWelcomeScreenViewController.h"
#import "QMLicenseAgreementViewController.h"
#import "QMSplashViewController.h"
#import "QMApi.h"
#import "QMSettingsManager.h"
#import "SVProgressHUD.h"
#import "REAlertView.h"

@interface QMWelcomeScreenViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *bubleImage;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bubleHeight;

- (IBAction)connectWithFacebook:(id)sender;

@end

@implementation QMWelcomeScreenViewController

- (void)dealloc {
    NSLog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.bubleHeight.constant = IS_HEIGHT_GTE_568 ? 244 : 197;
    self.bubleImage.image = [UIImage imageNamed:IS_HEIGHT_GTE_568 ? @"logo_big" : @"logo_big_960"];
    [[QMApi instance].settingsManager defaultSettings];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

#pragma mark - Actions

- (IBAction)connectWithFacebook:(id)sender {
    
    __weak __typeof(self)weakSelf = self;
    [self checkForAcceptedUserAgreement:^(BOOL success) {
        if (success) {
            [weakSelf signInWithFacebook];
        }
    }];
}

- (IBAction)signUpWithEmail:(id)sender
{
    [self performSegueWithIdentifier:kSignUpSegueIdentifier sender:nil];
}

- (IBAction)pressAlreadyBtn:(id)sender
{
    [self performSegueWithIdentifier:kLogInSegueSegueIdentifier sender:nil];
}

- (void)checkForAcceptedUserAgreement:(void(^)(BOOL success))completion {
    
    BOOL licenceAccepted = [[QMApi instance].settingsManager userAgreementAccepted];
    if (licenceAccepted) {
        completion(YES);
    }
    else {
        QMLicenseAgreementViewController *licenceController =
        [self.storyboard instantiateViewControllerWithIdentifier:@"QMLicenceAgreementControllerID"];
        licenceController.licenceCompletionBlock = completion;
        [self.navigationController pushViewController:licenceController animated:YES];
    }
}

- (void)signInWithFacebook {
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    
    __weak __typeof(self)weakSelf = self;
    [[QMApi instance] singUpAndLoginWithFacebook:^(BOOL success) {
        
        [SVProgressHUD dismiss];
        if (success) {
            [weakSelf performSegueWithIdentifier:kTabBarSegueIdnetifier sender:nil];
        }
    }];
}

@end
