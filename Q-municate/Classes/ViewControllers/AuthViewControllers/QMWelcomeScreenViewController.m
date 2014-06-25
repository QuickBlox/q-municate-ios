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
    
    [QMUtilities showActivityView];
    [[QMAuthService shared] authWithFacebookAndCompletionHandler:^(QBUUser *user, BOOL success, NSString *error) {
        
        if (!success) {
            [QMUtilities hideActivityView];
            [self showAlertWithMessage:error actionSuccess:NO];
            return;
        }
        
        // remember me with facebook login:
        settingsManager.rememberMe = YES;
        
        // subscribe to push notification:
        [[QMAuthService shared] subscribeToPushNotifications];
        
        // save me:
        [[QMContactList shared] setMe:user];
        if (user.blobID == 0 || user.website == nil) {
            [[QMAuthService shared] loadFacebookUserPhotoAndUpdateUser:user completion:^(BOOL success) {
                if (success) {
                    [self logInToQuickbloxChatWithUser:user];
                }
            }];
            return;
        }
        [self logInToQuickbloxChatWithUser:user];
    }];
}


#pragma mark -

- (void)logInToQuickbloxChatWithUser:(QBUUser *)user {
    // login to Quickblox chat:
    [[QMChatService shared] loginWithUser:user completion:^(BOOL success) {
        [QMUtilities hideActivityView];
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
