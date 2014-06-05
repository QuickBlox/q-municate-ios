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

@interface QMSplashViewController ()

@property (nonatomic) BOOL isAlreadySeen;

@end

@implementation QMSplashViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // start utilities singleton:
    [QMUtilities shared];
    
    [QMUtilities createIndicatorView];
    //start session:
    [[QMAuthService shared] startSessionWithBlock:^(BOOL success, NSError *error) {
        if (!success) {
            [QMUtilities removeIndicatorView];
            [self showAlertWithMessage:error.description actionSuccess:NO];
            return;
        }
        ILog(@"Session created");
        
        // load defaults:
        NSString *email = [[NSUserDefaults standardUserDefaults] objectForKey:kEmail];
        email = [email stringByReplacingOccurrencesOfString:@"+" withString:@"%2b"];
        NSString *password = [[NSUserDefaults standardUserDefaults] objectForKey:kPassword];
        
        // if user with email was remebered:
        if (email != nil && password != nil) {
            // login automatically:
            [self loginWithEmail:email password:password];
            return;
        }
        [QMUtilities removeIndicatorView];
        [self showWelcomeScreen];
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showWelcomeScreen
{
    [self performSegueWithIdentifier:kWelcomeScreenSegueIdentifier sender:nil];
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    QMWelcomeScreenViewController *welcomeScreenVC = segue.destinationViewController;
    welcomeScreenVC.root = self;
}

- (void)loginWithEmail:(NSString *)email password:(NSString *)password
{
    [QMUtilities createIndicatorView];
    [[QMAuthService shared] logInWithEmail:email password:password completion:^(QBUUser *user, BOOL success, NSError *error) {
        if (!success) {
            [QMUtilities removeIndicatorView];
            [self showAlertWithMessage:[NSString stringWithFormat:@"%@", error] actionSuccess:NO];
            return;
        }
        [QMContactList shared].me = user;
        if (!user.password) {
            user.password = password;
        }
        
        [[QMChatService shared] loginWithUser:user completion:^(BOOL success) {
            [QMUtilities removeIndicatorView];
            if (success) {
                //pop auth and push tab bar:
                UIWindow *window = (UIWindow *)[[UIApplication sharedApplication].windows firstObject];
                UINavigationController *navigationController = (UINavigationController *)window.rootViewController;
                [navigationController popToRootViewControllerAnimated:NO];
            }
        }];
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
