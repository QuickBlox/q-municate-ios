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
#import "QMChatService.h"
#import "QMSettingsManager.h"
#import "QMUsersService.h"

@implementation QMApi (Auth)

#pragma mark Public methods

- (void)logout:(void(^)(BOOL success))completion {
    
    [self.chatService logout];
    [self.facebookService logout];
    [self.settingsManager clearSettings];
    [self stopServices];
    self.currentUser = nil;
    completion(YES);
}

- (void)setAutoLogin:(BOOL)autologin {
    self.settingsManager.rememberMe = autologin;
}

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
                    [weakSelf logInWithFacebookAccessToken:sessionToken completion:^(BOOL successLoginWithFacebook) {
                        if (!successLoginWithFacebook) {
                            completion(successLoginWithFacebook);
                        }
                        else {
                            [weakSelf setAutoLogin:YES];
                            
                            void (^autorizeOnQuickBloxChat)(BOOL) = ^(BOOL success) {
                                
                                /*Authorize on QuickBlox Chat*/
                                [weakSelf autorizeOnQuickbloxChat:^(BOOL success) {
                                    [weakSelf fetchDataOrForce:!success completion:completion];
                                }];
                            };
                            
                            if (weakSelf.currentUser.website.length == 0) {
                                /*Update user image from facebook */
                                [weakSelf.facebookService loadMe:^(NSDictionary<FBGraphUser> *user) {
                                    
                                    NSURL *userImageUrl = [weakSelf.facebookService userImageUrlWithUserID:user.id];
                                    [weakSelf updateUser:weakSelf.currentUser imageUrl:userImageUrl progress:^(float progress) {
                                        NSLog(@"Upload user avatar %f", progress);
                                    } completion:autorizeOnQuickBloxChat];
                                    
                                }];
                            }
                            else {
                                autorizeOnQuickBloxChat(successLoginWithFacebook);
                            }
                        }
                    }];
                }
            }];
        }
    }];
}

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
                        [weakSelf autorizeOnQuickbloxChat:^(BOOL success) {
                            [weakSelf fetchDataOrForce:!success completion:completion];
                        }];
                    }];
                }
            }];
        }
    }];
}

- (void)fetchDataOrForce:(BOOL)force completion:(void(^)(BOOL success))completion {
    
    if (!force) {
        [self startServices];
        [self fetchAllHistory:^{}];
    }
    completion(!force);
}

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
                    [weakSelf autorizeOnQuickbloxChat:^(BOOL success) {
                        [weakSelf fetchDataOrForce:!success completion:completion];
                    }];
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

#pragma mark - Private methods

- (void)createSessionWithBlock:(void(^)(BOOL success))completion {
    
    __weak __typeof(self)weakSelf = self;
    [self.authService createSessionWithBlock:^(QBAAuthSessionCreationResult *result) {
        completion([weakSelf checkResult:result]);
    }];
}

- (void)logInWithFacebookAccessToken:(NSString *)accessToken completion:(void(^)(BOOL success))completion {
    
    __weak __typeof(self)weakSelf = self;
    [weakSelf.authService logInWithFacebookAccessToken:accessToken completion:^(QBUUserLogInResult *loginWithFBResult) {
        weakSelf.currentUser = loginWithFBResult.user;
        completion([weakSelf checkResult:loginWithFBResult]);
    }];
}

- (void)destroySessionWithCompletion:(void(^)(BOOL success))completion {
    
    __weak __typeof(self)weakSelf = self;
    [self.authService destroySessionWithCompletion:^(QBAAuthResult *result) {
        completion([weakSelf checkResult:result]);
    }];
}

- (void)subscribeToPushNotificationsIfNeeded {
    
    if (self.settingsManager.pushNotificationsEnabled) {
        __weak __typeof(self)weakSelf = self;
        [self.authService subscribeToPushNotifications:^(QBMRegisterSubscriptionTaskResult *result) {
            [weakSelf checkResult:result];
        }];
    }
}

- (void)autorizeOnQuickbloxChat:(void(^)(BOOL success))completion {
    
    __weak __typeof(self)weakSelf = self;
    /*Authorize on QuickBlox Chat*/
    if (!self.currentUser) {
        completion(NO);
    }
    else {
        [self.chatService loginWithUser:self.currentUser completion:^(BOOL success) {
            if (!success) {
                completion(success);
            }
            else {
                completion(success);
                [weakSelf subscribeToPushNotificationsIfNeeded];
            }
        }];
    }
}

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

- (void)applicationDidBecomeActive:(void(^)(BOOL success))completion {
    
    [self autorizeOnQuickbloxChat:completion];

}

- (void)applicationWillResignActive {
    
    if ([self.chatService logout]) {
        [self stopServices];
    } else {
        NSLog(@"");
    }
}

@end
