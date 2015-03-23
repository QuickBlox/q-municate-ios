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
#import "REAlertView+QMSuccess.h"

@implementation QMApi (Auth)

#pragma mark Public methods

- (void)logout:(void(^)(BOOL success))completion {
    
    [self.messagesService logoutChat];
    self.currentUser = nil;
    [self.settingsManager clearSettings];
    [QMFacebookService logout];
    [self stopServices];
    
    [self unSubscribeToPushNotifications:^(BOOL success) {
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
        
        if (self.settingsManager.accountType == QMAccountTypeEmail && self.settingsManager.password && self.settingsManager.login) {
            
            NSString *email = self.settingsManager.login;
            NSString *password = self.settingsManager.password;
            
            [self loginWithEmail:email password:password rememberMe:YES completion:completion];
        }
        else if (self.settingsManager.accountType == QMAccountTypeFacebook) {
            
            [self loginWithFacebook:completion];
        }
        else {
            
            completion(NO);
        }
    }
    else {
        
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
            
            if (weakSelf.currentUser.avatarURL.length == 0) {
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
    
    [weakSelf.usersService resetUserPasswordWithEmail:email completion:^(QBResult *result) {
        completion([weakSelf checkResult:result]);
    }];
}

#pragma mark - Private methods

- (void)createSessionWithBlock:(void(^)(BOOL success))completion {
    
    if ([self.authService sessionTokenHasExpiredOrNeedCreate]) {
        
        [QBRequest createSessionWithSuccessBlock:^(QBResponse *response, QBASession *session) {
            completion(YES);
        } errorBlock:^(QBResponse *response) {
            [REAlertView showAlertWithMessage:response.error.description actionSuccess:NO];
            completion(NO);
        }];
    }
    else {
        completion(YES);
    }
}

- (void)destroySessionWithCompletion:(void(^)(BOOL success))completion {
    
    [QBRequest destroySessionWithSuccessBlock:^(QBResponse *response) {
        completion(YES);
    } errorBlock:^(QBResponse *response) {
        [REAlertView showAlertWithMessage:response.error.description actionSuccess:NO];
        completion(NO);
    }];
}

- (void)logInWithFacebookAccessToken:(NSString *)accessToken completion:(void(^)(BOOL success))completion {
    
    __weak __typeof(self)weakSelf = self;
    [self.authService logInWithFacebookAccessToken:accessToken completion:^(QBUUserLogInResult *loginWithFBResult) {
        
        if ([weakSelf checkResult:loginWithFBResult]) {
            
            weakSelf.currentUser = loginWithFBResult.user;
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
                completion(successLoginWithFacebook);
            }];
        }
    }];
}

- (void)subscribeToPushNotificationsForceSettings:(BOOL)force complete:(void(^)(BOOL success))complete {
    
    if( !self.deviceToken ){
        if( complete ){
            complete(NO);
        }
        return;
    }
    
    if (self.settingsManager.pushNotificationsEnabled || force) {
        __weak __typeof(self)weakSelf = self;
        
        // Register subscription with device token
        [QBRequest registerSubscriptionForDeviceToken:self.deviceToken successBlock:^(QBResponse *response, NSArray *subscriptions) {
            // Registration succeded
            if (force) {
                weakSelf.settingsManager.pushNotificationsEnabled = YES;
            }
            if (complete) {
                complete(YES);
            };
        } errorBlock:^(QBError *error) {
            // Handle error
            [REAlertView showAlertWithMessage:error.description actionSuccess:NO];
            if (complete) {
                complete(NO);
            };
        }];
        
    }
    else{
        if( complete ){
            complete(NO);
        }
    }
}

- (void)unSubscribeToPushNotifications:(void(^)(BOOL success))complete {
    
    if (self.settingsManager.pushNotificationsEnabled) {
        __weak __typeof(self)weakSelf = self;
        [QBRequest unregisterSubscriptionWithSuccessBlock:^(QBResponse *response) {
            weakSelf.settingsManager.pushNotificationsEnabled = NO;
            if (complete) {
                complete(YES);
            }
        } errorBlock:^(QBError *error) {
            if( ![error reasons] ) { // success unsubscription
                weakSelf.settingsManager.pushNotificationsEnabled = NO;
                if (complete) {
                    complete(YES);
                }
            }
            else{
                ILog(@"%@", error.description);
                if (complete) {
                    complete(NO);
                }
            }
        }];
    }
    else {
        
        if( complete ) {
            complete(YES);
        }
    }
}

- (void)loginWithEmail:(NSString *)email password:(NSString *)password rememberMe:(BOOL)rememberMe completion:(void(^)(BOOL success))completion {
    
    __weak __typeof(self)weakSelf = self;
    [self.authService logInWithEmail:email password:password completion:^(QBUUserLogInResult *loginResult) {
        
        if(![weakSelf checkResult:loginResult]){
            
            completion(loginResult.success);
        }
        else {
            
            weakSelf.currentUser = loginResult.user;
            weakSelf.currentUser.password = password;
            
            if (rememberMe) {
                weakSelf.settingsManager.rememberMe = rememberMe;
                [weakSelf.settingsManager setLogin:email andPassword:password];
            }
            
            completion(loginResult.success);
        }
    }];
}

@end
