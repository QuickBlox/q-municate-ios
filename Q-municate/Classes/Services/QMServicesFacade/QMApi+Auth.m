//
//  QMApi+Auth.m
//  Qmunicate
//
//  Created by Andrey Ivanov on 03.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMApi.h"
#import "QMAuthService.h"
#import "QMFacebookService.h"
#import "QMSettingsManager.h"
#import "QMUsersService.h"
#import "QMMessagesService.h"

@implementation QMApi (Auth)

#pragma mark Public methods

- (void)logout:(void(^)(BOOL success))completion {
    
    [self.messagesService logoutChat];
    self.currentUser = nil;
    [self.settingsManager clearSettings];
    [QMFacebookService logout];
    [self stopServices];
    
    [self.authService unSubscribeFromPushNotifications:^(QBMUnregisterSubscriptionTaskResult *result) {
        
        completion(YES);
    }];
}

- (void)setAutoLogin:(BOOL)autologin withAccountType:(QMAccountType)accountType {
    
    self.settingsManager.rememberMe = autologin;
    self.settingsManager.accountType = accountType;
}

- (void)autoLogin:(void(^)(BOOL success))completion {
    
    [self startServices];
    if (!self.currentUser) {
        
        if (self.settingsManager.accountType == QMAccountTypeEmail) {
            
            NSString *email = self.settingsManager.login;
            NSString *password = self.settingsManager.password;
            
            [self loginWithEmail:email password:password rememberMe:YES completion:completion];
        }
        else if (self.settingsManager.accountType == QMAccountTypeFacebook) {
            [self loginWithFacebook:completion];
        } else {
            NSAssert(nil, @"Need update this case");
        }
    } else {
        
        completion(YES);
    }
}

- (void)singUpAndLoginWithFacebook:(void(^)(BOOL success))completion {
    
    __weak __typeof(self)weakSelf = self;
    /*create QBSession*/
    [self loginWithFacebook:^(BOOL success) {
        
        if (!success) {
            completion(success);
        }
        else {
            [weakSelf setAutoLogin:YES withAccountType:QMAccountTypeFacebook];
            if (weakSelf.currentUser.website.length == 0) {
                /*Update user image from facebook */
                [QMFacebookService loadMe:^(NSDictionary<FBGraphUser> *user) {
                    
                    NSURL *userImageUrl = [QMFacebookService userImageUrlWithUserID:user.id];
                    [weakSelf updateUser:weakSelf.currentUser imageUrl:userImageUrl progress:nil completion:completion];
                    
                }];
            }
            else {
                completion(YES);
            }
        }
    }];
}

- (void)signUpAndLoginWithUser:(QBUUser *)user rememberMe:(BOOL)rememberMe completion:(void(^)(BOOL success))completion {
    
    __weak __typeof(self)weakSelf = self;
    
    [self.authService signUpUser:user completion:^(QBUUserResult *signUpResult) {
        if (![weakSelf checkResult:signUpResult]) {
            completion(signUpResult.success);
        }
        else {
            [weakSelf setAutoLogin:rememberMe withAccountType:QMAccountTypeEmail];
            [weakSelf loginWithEmail:user.email password:user.password rememberMe:rememberMe completion:completion];
        }
    }];
}

- (void)resetUserPassordWithEmail:(NSString *)email completion:(void(^)(BOOL success))completion {
    
    __weak __typeof(self)weakSelf = self;
    
    [weakSelf.usersService resetUserPasswordWithEmail:email completion:^(Result *result) {
        completion([weakSelf checkResult:result]);
    }];
}

#pragma mark - Private methods

- (void)createSessionWithBlock:(void(^)(BOOL success))completion {
    
    //get the current date
    void (^createQBSession)(void) = ^() {
        __weak __typeof(self)weakSelf = self;
        [weakSelf.authService createSessionWithBlock:^(QBAAuthSessionCreationResult *result) {
            if([weakSelf checkResult:result]){
                
                completion([weakSelf checkResult:result]);
            }
            else {
                completion(NO);
            }
        }];
    };
    
    if ([self.authService sessionTokenHasExpiredOrNeedCreate]) {
        createQBSession();
    }
    else {
        completion(YES);
    }
}

- (void)destroySessionWithCompletion:(void(^)(BOOL success))completion {
    
    __weak __typeof(self)weakSelf = self;
    [self.authService destroySessionWithCompletion:^(QBAAuthResult *result) {
        completion([weakSelf checkResult:result]);
    }];
}

- (void)logInWithFacebookAccessToken:(NSString *)accessToken completion:(void(^)(BOOL success))completion {
    
    __weak __typeof(self)weakSelf = self;
    [self.authService logInWithFacebookAccessToken:accessToken completion:^(QBUUserLogInResult *loginWithFBResult) {

        if ([weakSelf checkResult:loginWithFBResult]) {
            
            weakSelf.currentUser = loginWithFBResult.user;
            [weakSelf.usersService addUser:weakSelf.currentUser];
        }
        completion(loginWithFBResult.success);
    }];
}

- (void)loginWithFacebook:(void(^)(BOOL success))completion {
    
    /*open facebook session*/
    __weak __typeof(self)weakSelf = self;
    [QMFacebookService connectToFacebook:^(NSString *sessionToken) {
        if (!sessionToken) {
            completion(NO);
        }
        else {
            /*Longin with Social provider*/
            [weakSelf logInWithFacebookAccessToken:sessionToken completion:^(BOOL successLoginWithFacebook) {
                if (!successLoginWithFacebook) {
                    completion(successLoginWithFacebook);
                }
                else {
                    completion(YES);
                }
            }];
        }
    }];
}

- (void)subscribeToPushNotificationsForceSettings:(BOOL)force complete:(void(^)(BOOL success))complete {
    
    if (self.settingsManager.pushNotificationsEnabled || force) {
        __weak __typeof(self)weakSelf = self;
        [self.authService subscribeToPushNotifications:^(QBMRegisterSubscriptionTaskResult *result) {
            if (result.success && force) {
                weakSelf.settingsManager.pushNotificationsEnabled = YES;
            }
            if (complete)
                complete([weakSelf checkResult:result]);
        }];
    }
}

- (void)unSubscribeToPushNotifications:(void(^)(BOOL success))complete {
    
    if (self.settingsManager.pushNotificationsEnabled) {
        __weak __typeof(self)weakSelf = self;
        [self.authService unSubscribeFromPushNotifications:^(QBMUnregisterSubscriptionTaskResult *result) {
            
            if (![weakSelf checkResult:result]) {
                if (complete)
                    complete(NO);
            }
            else {
                weakSelf.settingsManager.pushNotificationsEnabled = NO;
                if (complete)
                    complete(YES);
            }
        }];
    }
}

- (void)loginWithEmail:(NSString *)email password:(NSString *)password rememberMe:(BOOL)rememberMe completion:(void(^)(BOOL success))completion {
    
    __weak __typeof(self)weakSelf = self;
    [self.authService logInWithEmail:email password:password completion:^(QBUUserLogInResult *loginResult) {
        
        if(![weakSelf checkResult:loginResult]){
            completion(loginResult.success);
        } else {
            
            weakSelf.currentUser = loginResult.user;
            weakSelf.currentUser.password = password;
            [weakSelf.usersService addUser:weakSelf.currentUser];
            
            if (rememberMe) {
                weakSelf.settingsManager.rememberMe = rememberMe;
                [weakSelf.settingsManager setLogin:email andPassword:password];
            }
            completion(loginResult.success);
        }
    }];
}

@end
