//
//  QMApi.m
//  Qmunicate
//
//  Created by Andrey on 01.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMApi.h"
#import "QMSettingsManager.h"
#import "QMFacebookService.h"
#import "QMAuthService.h"
#import "QMContactList.h"
#import "QMChatService.h"
#import "QMContent.h"
#import "REAlertView+QMSuccess.h"

@interface QMApi()

@property (strong, nonatomic) QMAuthService *authService;
@property (strong, nonatomic) QMSettingsManager *settingsManager;
@property (strong, nonatomic) QMFacebookService *facebookService;
@property (strong, nonatomic) QMContactList *contactList;

@end

@implementation QMApi

+ (instancetype)shared {
    
    static id authInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        authInstance = [[self alloc] init];
    });
    return authInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.authService = [[QMAuthService alloc] init];
        self.settingsManager = [[QMSettingsManager alloc] init];
        self.facebookService = [[QMFacebookService alloc] init];
        self.contactList = [QMContactList shared];
    }
    return self;
}

- (BOOL)checkResult:(Result *)result {
    
    if (result.success) {
        return YES;
    }
    else {
        [REAlertView showAlertWithMessage:result.errors.lastObject actionSuccess:NO];
        return NO;
    }
}

- (void)loginWithFacebook:(void(^)(BOOL success))completion {
    
    /*Open FBSession if needed*/
    __weak __typeof(self)weakSelf = self;
    [self.facebookService connectToFacebook:^(NSString *sessionToken) {
        
        if (!sessionToken) {
            completion(NO);
            return;
        }
        /*Login with facebook*/
        [weakSelf.authService logInWithFacebookAccessToken:sessionToken completion:^(QBUUserLogInResult *loginWithFBResult) {
            
            if ([self checkResult:loginWithFBResult]) {
                
                weakSelf.settingsManager.rememberMe = YES;
                [weakSelf.authService subscribeToPushNotifications];
                weakSelf.contactList.me = loginWithFBResult.user;
                
                if (!loginWithFBResult.user.website.length == 0) {

                    [weakSelf updateUserAvatarFromFacebook:^(QBUUserResult *result) {
                        [[QMChatService shared] loginWithUser:result.user completion:completion];
                    }];
                }
                [[QMChatService shared] loginWithUser:loginWithFBResult.user completion:completion];
            }
        }];
    }];
}

- (void)signUpAndLoginWithUser:(QBUUser *)user userAvatar:(UIImage *)userAvatar completion:(QBUUserResultBlock)completion {
    
    __weak __typeof(self)weakSelf = self;
    [self.authService signUpUser:user completion:^(QBUUserResult *signUpResult) {
        
        if ([weakSelf checkResult:signUpResult]) {
            
            [weakSelf loginWithUser:user completion:^(QBUUserLogInResult *loginResult) {
                
                if (userAvatar) {
                    NSString *imageName = [NSString stringWithFormat:@"%d", loginResult.user.ID];
                    [weakSelf updateUserAvatar:userAvatar imageName:imageName completion:completion];
                }
                completion(loginResult);
            }];
        } else {
            completion(signUpResult);
        }
    }];
}

- (void)loginWithUser:(QBUUser *)user completion:(QBUUserLogInResultBlock)complition {
    
    __weak __typeof(self)weakSelf = self;
    [self.authService logInWithEmail:user.email password:user.password completion:^(QBUUserLogInResult *loginResult) {
        
        loginResult.user.password = user.password;
        weakSelf.contactList.me = loginResult.user;
        
        if ([weakSelf checkResult:loginResult]) {
            [weakSelf.authService subscribeToPushNotifications];
            [[QMChatService shared] loginWithUser:loginResult.user completion:^(BOOL success) {
                
                if (success) {
                    complition (loginResult);
                } else {
                    NSAssert(NO, @"Update it");
                }
                
            }];
        }
    }];
}

#pragma mark - update user Avatar

- (void)updateUserAvatarFromFacebook:(QBUUserResultBlock)completion {

    __weak __typeof(self)weakSelf = self;
    [self.facebookService loadUserImageFromFacebookWithUserID:self.contactList.me.facebookID completion:^(UIImage *fbImage) {
        
        if (fbImage) {
            [weakSelf updateUserAvatar:fbImage imageName:weakSelf.contactList.me.facebookID completion:completion];
        }
    }];
}

- (void)updateUserAvatar:(UIImage *)image imageName:(NSString *)imageName completion:(QBUUserResultBlock)completion {
    
    QMContent *content = [[QMContent alloc] init];
    
    [content uploadImage:image named:imageName completion:^(QBCFileUploadTaskResult *result) {
        
        if ([self checkResult:result]) {
            
            QBUUser *user = self.contactList.me;
            user.oldPassword = user.password;
            user.website = [result.uploadedBlob publicUrl];
            
            [self.authService updateUser:user withCompletion:^(QBUUserResult *updateResult) {
                
                if ([self checkResult:updateResult]) {
                    
                    updateResult.user.password = self.contactList.me.password;
                    self.contactList.me = updateResult.user;
                }
                
                if (completion) completion(updateResult);
            }];
        }
    }];
}

@end
