//
//  QMApi+Auth.m
//  Qmunicate
//
//  Created by Andrey on 03.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMApi.h"
#import "QMAuthService.h"
#import "QMFacebookService.h"
#import "QMChatService.h"
#import "QMSettingsManager.h"
#import "QMUsersService.h"

@implementation QMApi (Auth)

- (void)logout:(void(^)(BOOL success))completion {

    [self destroySessionWithCompletion:^(BOOL success) {
        if (!success) {
            completion(success);
        }
        else {
            [self.settingsManager clearSettings];
            [self.chatService logout];
            [self.facebookService logout];
            [self cleanUp];
            completion(success);
        }
    }];
}
/*Public*/
- (void)setAutoLogin:(BOOL)autologin {
    self.settingsManager.rememberMe = autologin;
}
/*Private*/
- (void)createSessionWithBlock:(void(^)(BOOL success))completion {
    
    __weak __typeof(self)weakSelf = self;
    [self.authService createSessionWithBlock:^(QBAAuthSessionCreationResult *result) {
        completion([weakSelf checkResult:result]);
    }];
}
/*Private*/
- (void)logInWithFacebookAccessToken:(NSString *)accessToken completion:(void(^)(BOOL success))completion {
    
    __weak __typeof(self)weakSelf = self;
    [weakSelf.authService logInWithFacebookAccessToken:accessToken completion:^(QBUUserLogInResult *loginWithFBResult) {
        weakSelf.currentUser = loginWithFBResult.user;
        completion([weakSelf checkResult:loginWithFBResult]);
    }];
}
/*Private*/
- (void)destroySessionWithCompletion:(void(^)(BOOL success))completion {
    
    __weak __typeof(self)weakSelf = self;
    [self.authService destroySessionWithCompletion:^(QBAAuthResult *result) {
        completion([weakSelf checkResult:result]);
    }];
}
/*Private*/
- (void)subscribeToPushNotificationsIfNeeded {

    if (self.settingsManager.pushNotificationsEnabled) {
        __weak __typeof(self)weakSelf = self;
        [self.authService subscribeToPushNotifications:^(QBMRegisterSubscriptionTaskResult *result) {
            [weakSelf checkResult:result];
        }];
    }
}
/*Private*/
- (void)autorizeOnQuickbloxChat:(void(^)(BOOL success))completion {

    __weak __typeof(self)weakSelf = self;
    /*Authorize on QuickBlox Chat*/
    [self.chatService loginWithUser:self.currentUser completion:^(BOOL success) {
        if (!success) {
            completion(success);
        }
        else {
            [weakSelf fetchAllHistory:^{}];
            completion(success);
            [weakSelf subscribeToPushNotificationsIfNeeded];
        }
    }];
}
/*Public*/
- (void)loginWithFacebook:(void(^)(BOOL success))completion {
    
    __weak __typeof(self)weakSelf = self;
    /*open facebook session*/
    [self.facebookService connectToFacebook:^(NSString *sessionToken) {
        if (!sessionToken) {
            completion(NO);
        }
        else {
            /*create QBSession*/
            [weakSelf createSessionWithBlock:^(BOOL success) {
                if (!success) {
                    completion(success);
                }
                else {
                    /*Longin with Social provider*/
                    [weakSelf logInWithFacebookAccessToken:sessionToken completion:^(BOOL success) {
                        if (!success) {
                            completion(success);
                        }
                        else {
                            [weakSelf setAutoLogin:YES];
                            /*Authorize on QuickBlox Chat*/
                            [weakSelf autorizeOnQuickbloxChat:completion];
                        }
                    }];
                }
            }];
        }
    }];
}
/*Private*/
- (void)loginWithEmail:(NSString *)email password:(NSString *)password completion:(void(^)(BOOL success))completion {

    __weak __typeof(self)weakSelf = self;
    [self.authService logInWithEmail:email password:password completion:^(QBUUserLogInResult *loginResult) {
        
        weakSelf.currentUser = loginResult.user;
        weakSelf.currentUser.password = password;

        if(![weakSelf checkResult:loginResult]){
            completion(loginResult.success);
        } else {
            if (weakSelf.settingsManager.rememberMe) {
                [weakSelf.settingsManager setLogin:email andPassword:password];
            }
            completion(loginResult.success);
        }
    }];
}
/*Public*/
- (void)signUpAndLoginWithUser:(QBUUser *)user completion:(void(^)(BOOL success))completion {
    
    __weak __typeof(self)weakSelf = self;
    [self createSessionWithBlock:^(BOOL success) {
        if (!success) {
            completion(success);
        }
        else {
            [weakSelf.authService signUpUser:user completion:^(QBUUserResult *signUpResult) {
                
                if (![weakSelf checkResult:signUpResult]) {
                    completion(signUpResult.success);
                }
                else {
                    [weakSelf loginWithEmail:user.email password:user.password completion:^(BOOL success) {
                        [weakSelf autorizeOnQuickbloxChat:completion];
                    }];
                }
            }];
        }
    }];
}
/*Public*/
- (void)loginWithUser:(QBUUser *)user completion:(void(^)(BOOL success))completion {
    
    __weak __typeof(self)weakSelf = self;
    [self createSessionWithBlock:^(BOOL success) {
        if (!success) {
            completion (success);
        }
        else {
            [weakSelf loginWithEmail:user.email password:user.password completion:^(BOOL success) {
                if (!success) {
                    completion(success);
                }
                else {
                    [weakSelf autorizeOnQuickbloxChat:completion];
                }
            }];
        }
    }];
}

- (void)resetUserPassordWithEmail:(NSString *)email completion:(void(^)(BOOL success))completion {
    
    __weak __typeof(self)weakSelf = self;
    [self createSessionWithBlock:^(BOOL success) {
        if (!success) {
            completion(success);
        } else {
            
            [weakSelf.usersService resetUserPasswordWithEmail:email completion:^(Result *result) {
                completion([weakSelf checkResult:result]);
            }];
        }
    }];
}

@end
