//
//  QMApi+Auth.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 9/24/15.
//  Copyright © 2015 Quickblox. All rights reserved.
//

#import "QMApi.h"
#import <QMAuthService.h>
#import "QMFacebookService.h"
#import "QMSettingsManager.h"
#import "REAlertView+QMSuccess.h"

@implementation QMApi (Auth)

#pragma mark Public methods

- (void)logout:(void(^)(BOOL success))completion {
    
    __weak typeof(self)weakSelf = self;
    
    dispatch_group_t logoutGroup = dispatch_group_create();
    dispatch_group_enter(logoutGroup);
    [self.authService logOut:^(QBResponse *response) {
        __typeof(self) strongSelf = weakSelf;
        [strongSelf.chatService logoutChat];
        [strongSelf.chatService free];
        dispatch_group_leave(logoutGroup);
    }];
    
    dispatch_group_enter(logoutGroup);
    [[QMChatCache instance] deleteAllDialogs:^{
        dispatch_group_leave(logoutGroup);
    }];
    
    dispatch_group_enter(logoutGroup);
    [[QMChatCache instance] deleteAllMessages:^{
        dispatch_group_leave(logoutGroup);
    }];
    
    [self.settingsManager clearSettings];
    [QMFacebookService logout];
    
    dispatch_group_notify(logoutGroup, dispatch_get_main_queue(), ^{
        __typeof(self)strongSelf = weakSelf;
        [strongSelf unSubscribeToPushNotifications:^(BOOL success) {
            completion(YES);
        }];
    });
}

- (void)setAutoLogin:(BOOL)autologin withAccountType:(QMAccountType)accountType {
    
    self.settingsManager.rememberMe = autologin;
    self.settingsManager.accountType = accountType;
}

- (void)autoLogin:(void(^)(BOOL success))completion {
    
    if (!self.isAuthorized) {
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
    [self loginWithFacebook:^(BOOL success) {
        
        if (!success) {
            completion(success);
        }
        else {
            
            [weakSelf setAutoLogin:YES withAccountType:QMAccountTypeFacebook];
            
            if (weakSelf.currentUser.avatarUrl.length == 0) {
                /*Update user image from facebook */
                [QMFacebookService loadMe:^(NSDictionary *user) {
                    
                    NSURL *userImageUrl = [QMFacebookService userImageUrlWithUserID:[user valueForKey:@"id"]];
                    [weakSelf updateCurrentUser:nil imageUrl:userImageUrl progress:nil completion:completion];
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
    
    [self.authService signUpAndLoginWithUser:user completion:^(QBResponse *response, QBUUser *userProfile) {
        //
        if (response.success) {
            [weakSelf setAutoLogin:rememberMe withAccountType:QMAccountTypeEmail];
            if (rememberMe) {
                weakSelf.settingsManager.rememberMe = rememberMe;
                [weakSelf.settingsManager setLogin:user.email andPassword:user.password];
            }
        }
        completion(response.success);
    }];
}

- (void)resetUserPassordWithEmail:(NSString *)email completion:(void(^)(BOOL success))completion {

    [QBRequest resetUserPasswordWithEmail:email successBlock:^(QBResponse *response) {
        //
        completion(response.success);
    } errorBlock:^(QBResponse *response) {
        //
        completion(response.success);
    }];
}

#pragma mark - Private methods

- (void)logInWithFacebookAccessToken:(NSString *)accessToken completion:(void(^)(BOOL success))completion {
    
    __weak __typeof(self)weakSelf = self;
    [self.authService logInWithFacebookSessionToken:accessToken completion:^(QBResponse *response, QBUUser *userProfile) {
        //
        if (!response.success) {
            [weakSelf handleErrorResponse:response];
        }
        completion(response.success);
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

        NSString *deviceIdentifier = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        
        // subscribing for push notifications
        QBMSubscription *subscription = [QBMSubscription subscription];
        subscription.notificationChannel = QBMNotificationChannelAPNS;
        subscription.deviceUDID = deviceIdentifier;
        subscription.deviceToken = self.deviceToken;
        
        [QBRequest createSubscription:subscription successBlock:^(QBResponse *response, NSArray *objects) {
            // Registration succeded
            if (force) {
                weakSelf.settingsManager.pushNotificationsEnabled = YES;
            }
            if (complete) {
                complete(YES);
            };
        } errorBlock:^(QBResponse *response) {
            // Handle error
            [REAlertView showAlertWithMessage:response.error.description actionSuccess:NO];
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
        NSString *deviceIdentifier = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        [QBRequest unregisterSubscriptionForUniqueDeviceIdentifier:deviceIdentifier successBlock:^(QBResponse *response) {
            //
            weakSelf.settingsManager.pushNotificationsEnabled = NO;
            if (complete) {
                complete(YES);
            }
        } errorBlock:^(QBError *error) {
            //
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
    
    QBUUser *loginUser = [QBUUser user];
    loginUser.email =       email;
    loginUser.password =    password;
    
    [self.authService logInWithUser:loginUser completion:^(QBResponse *response, QBUUser *userProfile) {
        //
        if (response.success) {
            weakSelf.currentUser.password = password;
            
            if (rememberMe) {
                weakSelf.settingsManager.rememberMe = rememberMe;
                [weakSelf.settingsManager setLogin:email andPassword:password];
            }
        }
        completion(response.success);
    }];
}

@end
