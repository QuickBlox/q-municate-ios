//
//  QBAuthService.m
//  Q-municate
//
//  Created by Igor Alefirenko on 13/02/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMAuthService.h"

@interface QMAuthService () <QBActionStatusDelegate>

@property (copy, nonatomic) QBResultBlock resultBlock;

@end

@implementation QMAuthService

#pragma mark -
#pragma mark - Authorization

- (void)signUpUser:(QBUUser *)user completion:(QBUUserResultBlock)completion {
    [QBUsers signUp:user delegate:self context:Block_copy((__bridge void *)(completion))];
}

- (void)destroySessionWithCompletion:(QBAAuthResultBlock)completion {
    [QBAuth destroySessionWithDelegate:self context:Block_copy((__bridge void *)(completion))];
}

- (void)logInWithEmail:(NSString *)email password:(NSString *)password completion:(QBUUserLogInResultBlock)complition {
    [QBUsers logInWithUserEmail:email password:password delegate:self context:Block_copy((__bridge void *)(complition))];
}

- (void)logInWithFacebookAccessToken:(NSString *)accessToken completion:(QBUUserLogInResultBlock)completion {

    void (^resultBlock) (QBUUserLogInResult *) =^ (QBUUserLogInResult *result) {
        result.user.password = [QBBaseModule sharedModule].token;
        completion(result);
    };
    
    [QBUsers logInWithSocialProvider:kFacebook
                         accessToken:accessToken
                   accessTokenSecret:nil
                            delegate:self
                             context:Block_copy(Block_copy((__bridge void *)(resultBlock)))];
    
}

- (void)resetUserPasswordForEmail:(NSString *)email completion:(QBResultBlock)completion {
    
    [QBUsers resetUserPasswordWithEmail:email delegate:self context:Block_copy((__bridge void *)(completion))];
}

- (void)updateUser:(QBUUser *)user withCompletion:(QBUUserResultBlock)completion {
    
    void (^resultBlock)(QBUUserResult *) =^(QBUUserResult *result) {
        completion(result);
    };
    
    [QBUsers updateUser:user delegate:self context:Block_copy((__bridge void *)(resultBlock))];
}

- (void)startSessionWithBlock:(QBAAuthSessionCreationResultBlock)completion {
    [QBAuth createSessionWithDelegate:self context:Block_copy((__bridge void *)(completion))];
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
