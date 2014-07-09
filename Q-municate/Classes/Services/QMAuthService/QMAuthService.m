//
//  QBAuthService.m
//  Q-municate
//
//  Created by Igor Alefirenko on 13/02/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMAuthService.h"
#import "QBEchoObject.h"

@implementation QMAuthService

#pragma mark Create/Destroy Quickblox Sesson

- (void)createSessionWithBlock:(QBAAuthSessionCreationResultBlock)completion {
    [QBAuth createSessionWithDelegate:[QBEchoObject instance] context:[QBEchoObject makeBlockForEchoObject:completion]];
}

- (void)destroySessionWithCompletion:(QBAAuthResultBlock)completion {
    [QBAuth destroySessionWithDelegate:[QBEchoObject instance] context:[QBEchoObject makeBlockForEchoObject:completion]];
}

#pragma mark - Authorization

- (void)signUpUser:(QBUUser *)user completion:(QBUUserResultBlock)completion {
    [QBUsers signUp:user delegate:[QBEchoObject instance] context:[QBEchoObject makeBlockForEchoObject:completion]];
}

- (void)logInWithEmail:(NSString *)email password:(NSString *)password completion:(QBUUserLogInResultBlock)completion {
    [QBUsers logInWithUserEmail:email password:password delegate:[QBEchoObject instance] context:[QBEchoObject makeBlockForEchoObject:completion]];
}

- (void)logInWithFacebookAccessToken:(NSString *)accessToken completion:(QBUUserLogInResultBlock)completion {
    
    void (^resultBlock) (QBUUserLogInResult *) =^ (QBUUserLogInResult *result) {
        result.user.password = [QBBaseModule sharedModule].token;
        completion(result);
    };
    
    [QBUsers logInWithSocialProvider:kFacebook
                         accessToken:accessToken
                   accessTokenSecret:nil
                            delegate:[QBEchoObject instance]
                             context:[QBEchoObject makeBlockForEchoObject:resultBlock]];
}

- (void)resetUserPasswordForEmail:(NSString *)email completion:(QBResultBlock)completion {
    [QBUsers resetUserPasswordWithEmail:email delegate:[QBEchoObject instance] context:[QBEchoObject makeBlockForEchoObject:completion]];
}

- (void)updateUser:(QBUUser *)user withCompletion:(QBUUserResultBlock)completion {
    [QBUsers updateUser:user delegate:[QBEchoObject instance] context:[QBEchoObject makeBlockForEchoObject:completion]];
}

#pragma mark - Push Notifications

- (void)subscribeToPushNotifications {
    // Subscribe Users to Push Notifications
    QBMRegisterSubscriptionTaskResultBlock subscibeResult =^(QBMRegisterSubscriptionTaskResult *result) {
        NSLog(@"Subscriptions - %@", result.subscriptions);
    };
    
    [QBMessages TRegisterSubscriptionWithDelegate:[QBEchoObject instance] context:[QBEchoObject makeBlockForEchoObject:subscibeResult]];
}

- (void)unSubscribeFromPushNotifications {
    // Unsubscribe Users to Push Notifications
    QBMRegisterSubscriptionTaskResultBlock unSubscibeResult =^(QBMRegisterSubscriptionTaskResult *result) {
        NSLog(@"Subscriptions - %@", result.subscriptions);
    };
    
    [QBMessages TUnregisterSubscriptionWithDelegate:[QBEchoObject instance] context:[QBEchoObject makeBlockForEchoObject:unSubscibeResult]];
}

@end
