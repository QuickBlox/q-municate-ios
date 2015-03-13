//
//  SplashControllerViewController.m
//  Q-municate
//
//  Created by Igor Alefirenko on 13/02/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMWelcomeVC.h"
#import "QMLicenseAgreement.h"
#import "SVProgressHUD.h"
#import "REAlertView.h"
#import "QMServicesManager.h"
#import "REAlertView+QMSuccess.h"
#import "QMFacebook.h"

@interface QMWelcomeVC ()

@end

@implementation QMWelcomeVC

- (void)dealloc {
    ILog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES
                                             animated:NO];
}

#pragma mark - Actions

- (IBAction)connectWithFacebook:(id)sender {
    
    __weak __typeof(self)weakSelf = self;
    [QMLicenseAgreement checkAcceptedUserAgreementInViewController:self completion:^(BOOL success) {
        //User acceted user greement
        if (success) {
            
            [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
            // Get facebook session token
            QMFacebook *facebook = [[QMFacebook alloc] init];
            [facebook openSession:^(NSString *sessionToken) {
                
                if (!sessionToken) {
                    
                    [SVProgressHUD showErrorWithStatus:@"Facebook error"];
                }
                else {
                    // Singin or login
                    [QM.authService logInWithFacebookSessionToken:sessionToken completion:^(QBResponse *response, QBUUser *tUser) {
                        
                        //Save profile to keychain
                        [QM.profile synchronizeWithUserData:tUser];
                        
                        [SVProgressHUD dismiss];
                        if (response.success) {
                            
                            [weakSelf performSegueWithIdentifier:kSceneSegueChat
                                                          sender:nil];
                        }
                        else {
                            
                            [SVProgressHUD showErrorWithStatus:response.error.error.localizedDescription];
                        }
                    }];
                }
            }];
        }
    }];
}

@end