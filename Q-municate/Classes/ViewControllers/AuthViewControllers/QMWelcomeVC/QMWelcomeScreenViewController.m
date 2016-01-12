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

- (void)chainFacebookConnect {
    
    @weakify(self);
    [[[[[QMFacebook connect] continueWithBlock:^id _Nullable(BFTask<NSString *> * _Nonnull task) {
        // Facebook connect
        return task.result == nil ? nil : [[QMCore instance].authService loginWithFacebookSessionToken:task.result];
    }] continueWithBlock:^id _Nullable(BFTask<QBUUser *> * _Nonnull task) {
        //
        if (task.isFaulted) {
            [REAlertView showAlertWithMessage:NSLocalizedString(@"QM_STR_FACEBOOK_LOGIN_FALED_ALERT_TEXT", nil) actionSuccess:NO];
        } else {
            @strongify(self);
            [self performSegueWithIdentifier:kQMSceneSegueMain sender:nil];
            
            [[QMCore instance].currentProfile synchronizeWithUserData:task.result];
            if (task.result.avatarUrl.length == 0) return [QMFacebook loadMe];
        }
        
        return nil;
    }] continueWithSuccessBlock:^id _Nullable(BFTask<NSDictionary *> * _Nonnull task) {
        // downloading user avatar from url
        NSURL *userImageUrl = [QMFacebook userImageUrlWithUserID:task.result[@"id"]];
        return [QMContent downloadImageWithUrl:userImageUrl];
    }] continueWithSuccessBlock:^id _Nullable(BFTask<UIImage *> * _Nonnull task) {
        // uploading image to content module
        return [[QMCore instance].currentProfile updateUserImage:task.result progress:nil];
    }];
}

@end
