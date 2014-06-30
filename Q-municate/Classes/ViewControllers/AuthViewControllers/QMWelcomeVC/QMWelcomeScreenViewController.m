//
//  SplashControllerViewController.m
//  Q-municate
//
//  Created by Igor Alefirenko on 13/02/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMWelcomeScreenViewController.h"
#import "QMAuthService.h"
#import "QMChatService.h"
#import "QMAddressBook.h"
#import "QMContactList.h"
#import "QMContent.h"
#import "QMUtilities.h"
#import "QMSplashViewController.h"
#import "QMFacebookService.h"
#import "QMSettingsManager.h"
#import "REAlertView.h"

@interface QMWelcomeScreenViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *bubleImage;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bubleHeight;

- (IBAction)connectWithFacebook:(id)sender;

@end

@implementation QMWelcomeScreenViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (IS_HEIGHT_GTE_568) {
        _bubleHeight.constant = 244;
        _bubleImage.image = [UIImage imageNamed:@"logo_big"];
    } else {
        _bubleHeight.constant = 197;
        _bubleImage.image = [UIImage imageNamed:@"logo_big_960"];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

#pragma mark - Actions

- (IBAction)connectWithFacebook:(id)sender {
    
    QMSettingsManager *settingsManager = [[QMSettingsManager alloc] init];
    QMFacebookService *fbService = [[QMFacebookService alloc] init];
    QMAuthService *authService = [QMAuthService shared];
    QMContactList *constactList = [QMContactList shared];

    /*Open FBSession if needed*/
    [fbService connectToFacebook:^(NSString *sessionToken) {
        /*Login with facebook*/
        [authService logInWithFacebookAccessToken:sessionToken
                                       completion:^(QBUUserLogInResult *loginWithFBResult) {
                                           
             if (loginWithFBResult.success) {
                 
                 settingsManager.rememberMe = YES;
                 [authService subscribeToPushNotifications];
                 constactList.me = loginWithFBResult.user;
                 
                 if (!loginWithFBResult.user.website.length == 0) {
                     /*Get user image from facebook*/
                     [fbService loadUserImageFromFacebookWithUserID:constactList.fbMe.id completion:^(UIImage *fbImage) {
                         
                         if (fbImage) {
                             
                             QMContent *content = [[QMContent alloc] init];
                             /*Upload */
                             [content uploadImage:fbImage named:constactList.fbMe.id completion:^(QBCFileUploadTaskResult *result) {
                                 if (result.success) {
                                     
                                     NSString *userPassword = loginWithFBResult.user.password;
                                     
                                     [[QMAuthService shared] updateUser:loginWithFBResult.user withBlob:result.uploadedBlob completion:^(QBUUserResult *updateResult) {
                                        
                                          if (updateResult.success) {
                                              
                                              updateResult.user.password = userPassword;
                                              
                                              if (updateResult.user.email.length == 0) {
                                                  NSString *email = [QMContactList shared].fbMe[@"mail"];
                                                  updateResult.user.email = email;
                                              }
                                              
                                              constactList.me = updateResult.user;
                                              [self logInToQuickbloxChatWithUser:updateResult.user];
                                          }
                                      }];
                                 }
                             }];
                         }
                     }];
                 }
                 [self logInToQuickbloxChatWithUser:loginWithFBResult.user];
             } else {
                 [self showAlertWithMessage:loginWithFBResult.errors.lastObject actionSuccess:NO];
             }
         }];
    }];
}

#pragma mark -

- (void)logInToQuickbloxChatWithUser:(QBUUser *)user {
    // login to Quickblox chat:
    [[QMChatService shared] loginWithUser:user completion:^(BOOL success) {
        if (success) {
            [self performSegueWithIdentifier:kTabBarSegueIdnetifier sender:nil];
		}
    }];
}

- (void)showAlertWithMessage:(NSString *)messageString actionSuccess:(BOOL)success {
    
    [REAlertView presentAlertViewWithConfiguration:^(REAlertView *alertView) {
        alertView.title = success ? kAlertTitleSuccessString : kAlertTitleErrorString;
        alertView.message = messageString;
        [alertView addButtonWithTitle:kAlertButtonTitleOkString andActionBlock:^{}];
    }];
}

@end
