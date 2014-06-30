//
//  QBAuthService.m
//  Q-municate
//
//  Created by Igor Alefirenko on 13/02/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMAuthService.h"
#import "QMFacebookService.h"
#import "QMContactList.h"
//#import "QMChatService.h"
#import "QMUtilities.h"
#import "QMContent.h"


@interface QMAuthService () <QBActionStatusDelegate>

@property (copy, nonatomic) QBResultBlock resultBlock;

@end

@implementation QMAuthService

+ (instancetype)shared {
    
    static id authInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        authInstance = [[self alloc] init];
    });
    return authInstance;
}

#pragma mark -
#pragma mark - Authorization

- (void)signUpUser:(QBUUser *)user completion:(QBAuthResultBlock)completion {
    
    void (^resultBlock)(QBUUserResult *) = ^(QBUUserResult *result) {
        completion(result.user, result.success, result.errors.firstObject);
    };
    
    [QBUsers signUp:user delegate:self context:Block_copy(Block_copy((__bridge void *)(resultBlock)))] ;
}

- (void)destroySessionWithCompletion:(QBChatResultBlock)completion {
    
    void (^resultBlock)(QBAAuthResult *) =^(QBAAuthResult *result) {
        completion(result.success);
    };
    
    [QBAuth destroySessionWithDelegate:self context:Block_copy(Block_copy((__bridge void *)(resultBlock)))];
}

- (void)logInWithEmail:(NSString *)email password:(NSString *)password completion:(QBAuthResultBlock)complition {
    
    void (^resultBlock)(QBUUserLogInResult *) =^(QBUUserLogInResult *result) {
        complition(result.user, result.success, result.errors.firstObject);
    };
    
    [QBUsers logInWithUserEmail:email password:password delegate:self context:Block_copy(Block_copy((__bridge void *)(resultBlock)))];
}

- (void)logInWithFacebookAccessToken:(NSString *)accessToken completion:(QBAuthResultBlock)completion {

    void (^resultBlock) (QBUUserLogInResult *) =^ (QBUUserLogInResult *result) {
        result.user.password = [QBBaseModule sharedModule].token;
        completion(result.user, result.success, result.errors.lastObject);
    };
    
    [QBUsers logInWithSocialProvider:kFacebook
                         accessToken:accessToken
                   accessTokenSecret:nil
                            delegate:self
                             context:Block_copy(Block_copy((__bridge void *)(resultBlock)))];
    
}

- (void)resetUserPasswordForEmail:(NSString *)email completion:(QBResultBlock)completion {
    
    [QBUsers resetUserPasswordWithEmail:email delegate:self context:Block_copy(Block_copy((__bridge void *)(completion)))];
}

- (void)updateUser:(QBUUser *)user withBlob:(QBCBlob *)blob completion:(QBAuthResultBlock)completion {
    
    user.oldPassword = user.password;
    user.website = [blob publicUrl];
    [self updateUser:user withCompletion:completion];
}

- (void)updateUser:(QBUUser *)user withCompletion:(QBAuthResultBlock)completion {
    
    void (^resultBlock)(QBUUserResult *) =^(QBUUserResult *result) {
        
        [QMContactList shared].me = result.user;
        completion(result.user, result.success, result.errors.firstObject);
    };
    
    [QBUsers updateUser:user delegate:self context:Block_copy((__bridge void *)(resultBlock))];
}

- (void)startSessionWithBlock:(QBSessionCreationBlock)block {
    
    void (^resultBlock)(QBAAuthSessionCreationResult*) =^(QBAAuthSessionCreationResult *result) {
            block(result.success, result.errors.firstObject);
    };
    
    [QBAuth createSessionWithDelegate:self context:Block_copy((__bridge void *)(resultBlock))];
}

#pragma mark - Options

- (void)loadFacebookUserPhotoAndUpdateUser:(QBUUser *)user completion:(QBChatResultBlock)handler
{
    // upload photo:
    QMFacebookService *facebookService = [[QMFacebookService alloc] init];
    
    NSString *fbUserID = [QMContactList shared].fbMe.id;
    
    [facebookService loadUserImageFromFacebookWithUserID:fbUserID completion:^(UIImage *img) {
        
        if (img) {
            
            QMContent *contentStorage = [[QMContent alloc] init];
            [contentStorage loadImageForBlob:img named:[QMContactList shared].fbMe.id completion:^(QBCBlob *blob) {
                if (blob) {
                    // update user with new blob:
                    NSString *userPassword = user.password;

                    [[QMAuthService shared] updateUser:user withBlob:blob completion:^(QBUUser *user, BOOL success, NSString *error) {
                        
                        if (success) {
                            user.password = userPassword;
                            if (user.email == nil || [user.email isEqualToString:kEmptyString]) {
                                NSString *email = [QMContactList shared].fbMe[@"mail"];
                                user.email = email;
                            }
                            [[QMContactList shared] setMe:user];
                            handler(YES);
                        }
                    }];
                }
            }];
            
        }
        
    }];
}

#pragma mark - Push Notifications
- (void)subscribeToPushNotifications {
    // Subscribe Users to Push Notifications
    [QBMessages TRegisterSubscriptionWithDelegate:self];
}

- (void)unSubscribeFromPushNotifications {
    // Unsubscribe Users to Push Notifications
    [QBMessages TUnregisterSubscriptionWithDelegate:self];
}

#pragma mark - QBActionStatusDelegate

- (void)completedWithResult:(Result *)result context:(void *)contextInfo {
    
    ((__bridge void (^)(Result * result))(contextInfo))(result);
    Block_release(contextInfo);
}

@end
