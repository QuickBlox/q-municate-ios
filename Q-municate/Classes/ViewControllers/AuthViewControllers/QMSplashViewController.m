//
//  QMSplashViewController.m
//  Q-municate
//
//  Created by lysenko.mykhayl on 3/24/14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMSplashViewController.h"
#import "QMWelcomeScreenViewController.h"
#import "QMAuthService.h"
#import "QMChatService.h"
#import "QMContactList.h"
#import "QMUtilities.h"
#import "QMSettingsManager.h"

@interface QMSplashViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *splashLogoView;

@end

@implementation QMSplashViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.splashLogoView setImage:[UIImage imageNamed:IS_HEIGHT_GTE_568 ? @"splash" : @"splash-960"]];

    // start utilities singleton:
    [QMUtilities shared];
    [QMUtilities showActivityView];
    //start session:
    
    QMSettingsManager *settingsManager = [[QMSettingsManager alloc] init];
    
    [[QMAuthService shared] startSessionWithBlock:^(BOOL success, NSError *error) {

        if (!success) {
            [QMUtilities hideActivityView];
            [self showAlertWithMessage:error.description actionSuccess:NO];
            return;
        }
        
        ILog(@"Session created");
        
        BOOL rememberMe = settingsManager.rememberMe;

        if (rememberMe) {
            
            NSString *email = settingsManager.login;
            NSString *password = settingsManager.password;
            
            // if user with email was remebered:
            if (email != nil && password != nil) {
                [self loginWithEmail:email password:password];
            } else {
                [self loginWithFacebook];
            }
            
            // check for fb session remembered:
            return;
        }
        // load defaults:
        
        // go to wellcome screen:
        [QMUtilities hideActivityView];
        [self showWelcomeScreen];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showWelcomeScreen
{
    [self performSegueWithIdentifier:kWelcomeScreenSegueIdentifier sender:nil];
}

- (void)loginWithEmail:(NSString *)email password:(NSString *)password {
    
    [QMUtilities showActivityView];
    [[QMAuthService shared] logInWithEmail:email password:password completion:^(QBUUser *user, BOOL success, NSError *error) {
        
        if (!success) {
            [QMUtilities hideActivityView];
            [self showAlertWithMessage:error.localizedDescription actionSuccess:NO];
            return;
        }
        
        [QMContactList shared].me = user;
        if (!user.password) {
            user.password = password;
        }
        
        // subscribe to push notification:
        [[QMAuthService shared] subscribeToPushNotifications];
        
        [[QMChatService shared] loginWithUser:user completion:^(BOOL success) {
    
            [QMUtilities hideActivityView];
            if (success) {
                //pop auth and push tab bar:
                UIWindow *window = (UIWindow *)[[UIApplication sharedApplication].windows firstObject];
                UINavigationController *navigationController = (UINavigationController *)window.rootViewController;
                [navigationController popToRootViewControllerAnimated:NO];
            }
        }];
    }];
}

- (void)loginWithFacebook
{
    // login with facebook:
    [[QMAuthService shared] authWithFacebookAndCompletionHandler:^(QBUUser *user, BOOL success, NSError *error) {
        if (!success) {
            [QMUtilities hideActivityView];
            [self showAlertWithMessage:error.description actionSuccess:NO];
            return;
        }
        // save me:
        [[QMContactList shared] setMe:user];
        
        // subscribe to push notification:
        [[QMAuthService shared] subscribeToPushNotifications];
        
        if (user.blobID == 0) {
            [[QMAuthService shared] loadFacebookUserPhotoAndUpdateUser:user completion:^(BOOL success) {
                if (!success) {
                    [QMUtilities hideActivityView];
                    [self showAlertWithMessage:error.description actionSuccess:NO];
                    return;
                }
                [self logInToQuickbloxChatWithUser:user];
            }];
            return;
        }
        [self logInToQuickbloxChatWithUser:user];
    
    }];
}

- (void)logInToQuickbloxChatWithUser:(QBUUser *)user
{
    // login to Quickblox chat:
    [[QMChatService shared] loginWithUser:user completion:^(BOOL success) {
        [QMUtilities hideActivityView];
        if (success) {
            [self performSegueWithIdentifier:kTabBarSegueIdnetifier sender:nil];
		}
    }];
}


#pragma mark - Alert

- (void)showAlertWithMessage:(NSString *)messageString actionSuccess:(BOOL)success
{
    NSString *title = nil;
    if (success) {
        title = kAlertTitleSuccessString;
    } else {
        title = kAlertTitleErrorString;
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:messageString
                                                   delegate:nil
                                          cancelButtonTitle:kAlertButtonTitleOkString
                                          otherButtonTitles:nil];
    [alert show];
}

@end
