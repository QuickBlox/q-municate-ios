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

@interface QMWelcomeScreenViewController ()

- (IBAction)connectWithFacebook:(id)sender;
- (IBAction)SignUp:(id)sender;
- (IBAction)LogIn:(id)sender;

@end

@implementation QMWelcomeScreenViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [QMUtilities shared];
    if (![QMAuthService shared].isSessionCreated) {
        [QMUtilities createIndicatorView];
        [[QMAuthService shared] startSessionWithBlock:^(BOOL success, NSError *error) {
            [QMUtilities removeIndicatorView];
            if (success) {
                ILog(@"Session created");
            } else {
                [[[UIAlertView alloc] initWithTitle:kAlertTitleErrorString message:[NSString stringWithFormat:@"%@", error] delegate:self cancelButtonTitle:kAlertButtonTitleOkString otherButtonTitles:nil] show];
            }
        }];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

	/*
	* there was a bug when choosing user's ava on sigh up page
	* -> switching to login view at once!
	* https://jira-injoit.quickblox.com/browse/QMUN-90
	* */
	NSUInteger childControllersCount = [[self childViewControllers] count];
    if (!self.root && !childControllersCount) {
        [self logInToQuickblox];
    }
}

#pragma mark - Actions
- (IBAction)connectWithFacebook:(id)sender
{
    [QMUtilities createIndicatorView];
    [[QMAuthService shared] authWithFacebookAndCompletionHandler:^(QBUUser *user, BOOL success, NSError *error) {
        if (!success) {
            [QMUtilities removeIndicatorView];
            return;
        }
        // save me:
        [[QMContactList shared] setMe:user];
        if (user.blobID == 0) {
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

- (IBAction)SignUp:(id)sender
{
    [self signUpToQuickblox];
}

- (IBAction)LogIn:(id)sender
{
    [self logInToQuickblox];
}


#pragma mark - Authorization

- (void)signUpToQuickblox
{
    [self performSegueWithIdentifier:kSignUpSegueIdentifier sender:nil];
}

- (void)logInToQuickblox
{
    [self performSegueWithIdentifier:kLogInSegueSegueIdentifier sender:nil];
}


#pragma mark - Options

- (void)logInToQuickbloxChatWithUser:(QBUUser *)user
{
    // login to Quickblox chat:
    [[QMChatService shared] loginWithUser:user completion:^(BOOL success) {
        if (!success) {
            return;
        }
        [[QMContactList shared] findAndAddAllFriendsForFacebookUserWithCompletion:^(BOOL success) {
            [QMUtilities removeIndicatorView];
            [self dismissViewControllerAnimated:NO completion:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:kFriendsLoadedNotification object:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:kLoggedInNotification object:nil];
        }];
    }];
}

@end
