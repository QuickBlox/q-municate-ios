//
//  SplashControllerViewController.m
//  Q-municate
//
//  Created by Igor Alefirenko on 13/02/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMWelcomeScreenViewController.h"
#import "QMLicenseAgreement.h"
#import "SVProgressHUD.h"
#import "REAlertView.h"
#import "QMServicesManager.h"
#import "REAlertView+QMSuccess.h"

@interface QMWelcomeScreenViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *bubleImage;

@end

@implementation QMWelcomeScreenViewController

- (void)dealloc {
    ILog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.bubleImage.image = [UIImage imageNamed:IS_HEIGHT_GTE_568 ? @"logo_big" : @"logo_big_960"];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [self.navigationController setNavigationBarHidden:YES
                                             animated:NO];
}

#pragma mark - Actions

- (IBAction)connectWithFacebook:(id)sender {
    
    [QMLicenseAgreement checkAcceptedUserAgreementInViewController:self
                                                        completion:^(BOOL success)
     {
         if (success) {
             
             [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
             
             [QM.authService logInWithFacebookSessionToken:@""
                                                completion:^(QBResponse *response, QBUUser *tUser)
              {
                  
                  [SVProgressHUD dismiss];
                  if (response.success) {
                      
                      [self performSegueWithIdentifier:kTabBarSegueIdnetifier
                                                sender:nil];
                  }
              }];
         }
     }];
}

- (IBAction)signUpWithEmail:(id)sender {
    
    [self performSegueWithIdentifier:kSignUpSegueIdentifier
                              sender:nil];
}

- (IBAction)pressAlreadyBtn:(id)sender {
    
    [self performSegueWithIdentifier:kLogInSegueSegueIdentifier
                              sender:nil];
}

@end