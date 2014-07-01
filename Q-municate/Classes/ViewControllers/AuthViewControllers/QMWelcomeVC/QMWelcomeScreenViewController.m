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
#import "SVProgressHUD.h"

@interface QMWelcomeScreenViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *bubleImage;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bubleHeight;

- (IBAction)connectWithFacebook:(id)sender;

@end

@implementation QMWelcomeScreenViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.bubleHeight.constant = IS_HEIGHT_GTE_568 ? 244 : 197;
    self.bubleImage.image = [UIImage imageNamed:IS_HEIGHT_GTE_568 ? @"logo_big" : @"logo_big_960"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

#pragma mark - Actions

- (IBAction)connectWithFacebook:(id)sender {
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [[QMApi shared] loginWithFacebook:^(BOOL success) {
        [SVProgressHUD dismiss];
        if (success) {
            [self performSegueWithIdentifier:kTabBarSegueIdnetifier sender:nil];
        }
    }];
}

@end
