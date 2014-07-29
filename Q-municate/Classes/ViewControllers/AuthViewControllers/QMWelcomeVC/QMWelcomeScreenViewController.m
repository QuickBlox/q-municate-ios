//
//  SplashControllerViewController.m
//  Q-municate
//
//  Created by Igor Alefirenko on 13/02/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMWelcomeScreenViewController.h"
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.bubleHeight.constant = IS_HEIGHT_GTE_568 ? 244 : 197;
    self.bubleImage.image = [UIImage imageNamed:IS_HEIGHT_GTE_568 ? @"logo_big" : @"logo_big_960"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

#pragma mark - Actions

- (IBAction)connectWithFacebook:(id)sender {
    BOOL licenceAccepted = [[QMApi instance].settingsManager userAgreementAccepted];
    if (licenceAccepted) {
        [self signInWithFacebook];
        return;
    }
    [self signInWithFacebookAfterAcceptingUserAgreement];
}

- (void)signInWithFacebookAfterAcceptingUserAgreement
{
    [REAlertView presentAlertViewWithConfiguration:^(REAlertView *alertView) {
//        NSMutableAttributedString *attrMessage  = [[NSMutableAttributedString alloc] initWithString:@"By clicking Sign Up, you agree to Q-MUNICATE User Agreement."];
//        [attrMessage addAttributes:@{NSUnderlineStyleAttributeName:@(NSUnderlineStyleSingle)} range:NSMakeRange(10, 5)];
        alertView.message = @"By clicking Sign Up, you agree to Q-MUNICATE User Agreement.";
        [alertView addButtonWithTitle:kAlertButtonTitleOkString andActionBlock:^{
            [self signInWithFacebook];
            [[QMApi instance].settingsManager setUserAgreementAccepted:YES];
        }];
        [alertView addButtonWithTitle:@"Cancel" andActionBlock:nil];
    }];
}

- (void)signInWithFacebook
{
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    
    __weak __typeof(self)weakSelf = self;
    [[QMApi instance] loginWithFacebook:^(BOOL success) {
        
        [SVProgressHUD dismiss];
        if (success) {
            [weakSelf performSegueWithIdentifier:kTabBarSegueIdnetifier sender:nil];
        }
    }];
}

@end
