//
//  SplashControllerViewController.m
//  Q-municate
//
//  Created by Igor Alefirenko on 13/02/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMWelcomeScreenViewController.h"
#import "QMLicenseAgreement.h"
#import "REAlertView.h"
#import "REAlertView+QMSuccess.h"

#import "QMFacebook.h"
#import "QMCore.h"
#import "QMProfile.h"
#import "QMContent.h"
#import "QMTasks.h"

#import <DigitsKit/DigitsKit.h>

@implementation QMWelcomeScreenViewController

- (void)dealloc {
    ILog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

#pragma mark - Actions

- (IBAction)connectWithFacebook:(id)sender {
    @weakify(self);
    [QMLicenseAgreement checkAcceptedUserAgreementInViewController:self completion:^(BOOL success) {
        // License agreement check
        if (success) {
            @strongify(self);
            [self chainFacebookConnect];
        }
    }];
}

- (IBAction)connectWithPhoneNumber:(id)sender {
    @weakify(self);
    [QMLicenseAgreement checkAcceptedUserAgreementInViewController:self completion:^(BOOL success) {
        // License agreement check
        if (success) {
            @strongify(self);
            [self performDigitsLogin];
        }
    }];
}

- (void)chainFacebookConnect {
    @weakify(self);
    [[[QMFacebook connect] continueWithBlock:^id _Nullable(BFTask<NSString *> * _Nonnull task) {
        // Facebook connect
        return task.isFaulted || task.isCancelled ? nil : [[QMCore instance].authService loginWithFacebookSessionToken:task.result];
    }] continueWithBlock:^id _Nullable(BFTask<QBUUser *> * _Nonnull task) {
        //
        if (task.isFaulted) {
            [REAlertView showAlertWithMessage:NSLocalizedString(@"QM_STR_FACEBOOK_LOGIN_FALED_ALERT_TEXT", nil) actionSuccess:NO];
        } else if (task.result != nil) {
            @strongify(self);
            [self performSegueWithIdentifier:kQMSceneSegueMain sender:nil];
            [[QMCore instance].currentProfile synchronizeWithUserData:task.result];
            
            if (task.result.avatarUrl.length == 0) {
                return [[[QMFacebook loadMe] continueWithSuccessBlock:^id _Nullable(BFTask<NSDictionary *> * _Nonnull loadTask) {
                    // downloading user avatar from url
                    NSURL *userImageUrl = [QMFacebook userImageUrlWithUserID:loadTask.result[@"id"]];
                    return [QMContent downloadImageWithUrl:userImageUrl];
                }] continueWithSuccessBlock:^id _Nullable(BFTask<UIImage *> * _Nonnull imageTask) {
                    // uploading image to content module
                    return [[QMCore instance].currentProfile updateUserImage:imageTask.result progress:nil];
                }];
            }
        }
        
        return nil;
    }];
}

- (void)performDigitsLogin {
    @weakify(self);
    [[Digits sharedInstance] authenticateWithCompletion:^(DGTSession *session, NSError *error) {
        @strongify(self);
        // twitter digits auth
        if (error.userInfo.count > 0) {
            [REAlertView showAlertWithMessage:NSLocalizedString(@"QM_STR_FACEBOOK_LOGIN_FALED_ALERT_TEXT", nil) actionSuccess:NO];
        } else {
            DGTOAuthSigning *oauthSigning = [[DGTOAuthSigning alloc] initWithAuthConfig:[Digits sharedInstance].authConfig
                                                                            authSession:session];
            
            NSDictionary *authHeaders = [oauthSigning OAuthEchoHeadersToVerifyCredentials];
            if (!authHeaders) {
                // user seems skipped auth process
                return;
            }
            
            [[[QMCore instance].authService loginWithTwitterDigitsAuthHeaders:authHeaders] continueWithBlock:^id _Nullable(BFTask<QBUUser *> * _Nonnull task) {
                // login with twitter digits to REST
                if (!task.isFaulted) {
                    [self performSegueWithIdentifier:kQMSceneSegueMain sender:nil];
                    [[QMCore instance].currentProfile synchronizeWithUserData:task.result];
                }
                return nil;
            }];
        }
    }];
}

@end
