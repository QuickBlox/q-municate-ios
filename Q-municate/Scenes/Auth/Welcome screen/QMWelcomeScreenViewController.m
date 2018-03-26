//
//  SplashControllerViewController.m
//  Q-municate
//
//  Created by Igor Alefirenko on 13/02/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMWelcomeScreenViewController.h"
#import "QMLicenseAgreement.h"
#import "QMAlert.h"
#import "SVProgressHUD.h"

#import "QMFacebook.h"
#import "QMCore.h"
#import "QMContent.h"
#import "QMTasks.h"

#import <FirebaseCore/FirebaseCore.h>
#import <FirebaseAuth/FirebaseAuth.h>
#import <FirebasePhoneAuthUI/FUIPhoneAuth.h>

static NSString * const kQMFacebookIDField = @"id";

@interface QMWelcomeScreenViewController () <FUIAuthDelegate>

@end

@implementation QMWelcomeScreenViewController

- (void)dealloc {
    
    ILog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

//MARK: - Actions

- (IBAction)connectWithPhone {

    [QMLicenseAgreement checkAcceptedUserAgreementInViewController:self completion:^(BOOL success) {
        // License agreement check
        if (success) {
            [self performPhoneLogin];
        }
    }];
}

- (IBAction)loginWithEmailOrSocial:(UIButton *)sender {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"QM_STR_LOGIN_WITH_FACEBOOK", nil)
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull __unused action) {
                                                          
                                                          [QMLicenseAgreement checkAcceptedUserAgreementInViewController:self completion:^(BOOL success) {
                                                              // License agreement check
                                                              if (success) {
                                                                  
                                                                  [self chainFacebookConnect];
                                                              }
                                                          }];
                                                      }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"QM_STR_LOGIN_WITH_EMAIL", nil)
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull __unused action) {
                                                          
                                                          [self performSegueWithIdentifier:kQMSceneSegueLogin sender:nil];
                                                      }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"QM_STR_CANCEL", nil)
                                                        style:UIAlertActionStyleCancel
                                                      handler:nil]];
    
    if (alertController.popoverPresentationController) {
        // iPad support
        alertController.popoverPresentationController.sourceView = sender;
        alertController.popoverPresentationController.sourceRect = sender.bounds;
    }
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)chainFacebookConnect {
    
    
    [[[QMFacebook connect] continueWithBlock:^id _Nullable(BFTask<NSString *> * _Nonnull task) {
        // Facebook connect
        if (task.isFaulted || task.isCancelled) {
            
            return nil;
        }
        
        [SVProgressHUD show];
        
        return [QMCore.instance.authService loginWithFacebookSessionToken:task.result];
        
    }] continueWithBlock:^id _Nullable(BFTask<QBUUser *> * _Nonnull task) {
        
        if (task.isFaulted) {
            
            [QMFacebook logout];
        }
        else if (task.result != nil) {
            
            
            [SVProgressHUD dismiss];
            [self performSegueWithIdentifier:kQMSceneSegueMain sender:nil];
            QMCore.instance.currentProfile.accountType = QMAccountTypeFacebook;
            [QMCore.instance.currentProfile synchronizeWithUserData:task.result];
            
            if (task.result.avatarUrl.length == 0) {
                
                return [[[QMFacebook loadMe] continueWithSuccessBlock:^id _Nullable(BFTask<NSDictionary *> * _Nonnull loadTask) {
                    // downloading user avatar from url
                    NSURL *userImageUrl = [QMFacebook userImageUrlWithUserID:loadTask.result[kQMFacebookIDField]];
                    return [QMContent downloadImageWithUrl:userImageUrl];
                    
                }] continueWithSuccessBlock:^id _Nullable(BFTask<UIImage *> * _Nonnull imageTask) {
                    // uploading image to content module
                    return [QMTasks taskUpdateCurrentUserImage:imageTask.result progress:nil];
                }];
            }
        }
        
        return nil;
    }];
}

- (void)performPhoneLogin {
    
    FUIAuth *authUI = [FUIAuth defaultAuthUI];
    authUI.signInWithEmailHidden = YES;
    authUI.delegate = self;
    FUIPhoneAuth *phoneAuth = [[FUIPhoneAuth alloc] initWithAuthUI:authUI];
    authUI.providers = @[phoneAuth];
    [phoneAuth signInWithPresentingViewController:self
                                      phoneNumber:nil];
}

// MARK: - FUIAuthDelegate delegate

- (void)authUI:(FUIAuth *)__unused authUI didSignInWithUser:(FIRUser *)fuser error:(NSError *)ferror {
    
    if (ferror != nil) {
        
        if (ferror.userInfo.count > 0) {
            // only notify user if something happened in error
            // error without user info is cancel
            [QMAlert showAlertWithMessage:NSLocalizedString(@"QM_STR_UNKNOWN_ERROR", nil) actionSuccess:NO inViewController:self];
        }
        
        return;
    }
    
    [SVProgressHUD show];
    @weakify(self);
    [fuser getIDTokenWithCompletion:^(NSString * _Nullable token, NSError * _Nullable __unused error) {
        @strongify(self);
        
        [[[QMCore instance].authService logInWithFirebaseProjectID:[authUI auth].app.options.projectID accessToken:token] continueWithBlock:^id _Nullable(BFTask<QBUUser *> * _Nonnull task) {
            
            [SVProgressHUD dismiss];
            if (!task.isFaulted) {
                
                [self performSegueWithIdentifier:kQMSceneSegueMain sender:nil];
                
                QMCore.instance.currentProfile.accountType = QMAccountTypePhone;
                
                QBUUser *user = task.result;
                if (user.fullName.length == 0) {
                    // setting phone as user full name
                    user.fullName = user.phone;
                    
                    QBUpdateUserParameters *updateUserParams = [QBUpdateUserParameters new];
                    updateUserParams.fullName = user.fullName;
                    
                    [QMTasks taskUpdateCurrentUser:updateUserParams];
                }
                
                [QMCore.instance.currentProfile synchronizeWithUserData:user];
            }
            
            return nil;
        }];
    }];
}

@end
