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
    [self.navigationController setNavigationBarHidden:YES animated:NO];
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
    
    QMProfile *currentProfile = [QMProfile currentProfile];
    
    @weakify(self);
    [[[[[[[QMFacebook connect] continueWithBlock:^id _Nullable(BFTask<NSString *> * _Nonnull task) {
        // Facebook connect
        return task.isCompleted ? [[QMCore instance].authService loginWithFacebookSessionToken:task.result] : nil;
    }] continueWithBlock:^id _Nullable(BFTask<QBUUser *> * _Nonnull task) {
        //
        if (task.isCompleted) {
            @strongify(self);
            [self performSegueWithIdentifier:kQMSceneSegueMain sender:nil];
            
            [currentProfile synchronizeWithUserData:task.result];
            if (task.result.avatarUrl.length == 0) return [QMFacebook loadMe];
        } else {
            //
            [REAlertView showAlertWithMessage:NSLocalizedString(@"QM_STR_FACEBOOK_LOGIN_FALED_ALERT_TEXT", nil) actionSuccess:NO];
        }
        
        return nil;
    }] continueWithSuccessBlock:^id _Nullable(BFTask<NSDictionary *> * _Nonnull task) {
        // downloading user avatar from url
        NSURL *userImageUrl = [QMFacebook userImageUrlWithUserID:task.result[@"id"]];
        return [QMContent downloadImageWithUrl:userImageUrl];
    }] continueWithSuccessBlock:^id _Nullable(BFTask<UIImage *> * _Nonnull task) {
        // uploading image to content module
        return [QMContent uploadJPEGImage:task.result progress:nil];
    }] continueWithSuccessBlock:^id _Nullable(BFTask<QBCBlob *> * _Nonnull task) {
        // updating current user
        QBUpdateUserParameters *updateParameters = [QBUpdateUserParameters new];
        updateParameters.avatarUrl = task.result.isPublic ? task.result.publicUrl : task.result.privateUrl;
        return [QMTasks taskUpdateCurrentUser:updateParameters];
    }] continueWithSuccessBlock:^id _Nullable(BFTask<QBUUser *> * _Nonnull task) {
        // Syncronize profile
        [currentProfile synchronizeWithUserData:task.result];
        return nil;
    }];
}

@end
