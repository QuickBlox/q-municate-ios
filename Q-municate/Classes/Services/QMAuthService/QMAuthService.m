//
//  QBAuthService.m
//  Q-municate
//
//  Created by Ivanov Andrey on 13/07/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMAuthService.h"
#import "QBEchoObject.h"

@implementation QMAuthService

#pragma mark Create/Destroy Quickblox Sesson

- (BOOL)sessionTokenHasExpiredOrNeedCreate {
    
    QBBaseModule *baseModule = [QBBaseModule sharedModule];
    if (baseModule.tokenExpirationDate) {
        NSDate *currentDate = [NSDate date];
        NSTimeInterval interval = [currentDate timeIntervalSinceDate:baseModule.tokenExpirationDate];
        return interval > 0;
    }
    else {
        return YES;
    }
}

- (NSObject<Cancelable> *)createSessionWithBlock:(QBAAuthSessionCreationResultBlock)completion {
    return [QBAuth createSessionWithDelegate:[QBEchoObject instance] context:[QBEchoObject makeBlockForEchoObject:completion]];
}

- (NSObject<Cancelable> *)destroySessionWithCompletion:(QBAAuthResultBlock)completion {
    return [QBAuth destroySessionWithDelegate:[QBEchoObject instance] context:[QBEchoObject makeBlockForEchoObject:completion]];
}

#pragma mark - Authorization

- (NSObject<Cancelable> *)signUpUser:(QBUUser *)user completion:(QBUUserResultBlock)completion {
    return [QBUsers signUp:user delegate:[QBEchoObject instance] context:[QBEchoObject makeBlockForEchoObject:completion]];
}


- (NSObject<Cancelable> *)createQBAsessionAndAogInWithEmail:(NSString *)email
                                                   password:(NSString *)password
                                                 completion:(QBAAuthSessionCreationResultBlock)completion {
    
    QBASessionCreationRequest *extendedAuthRequest = [QBASessionCreationRequest request];
    extendedAuthRequest.userEmail = email;
    extendedAuthRequest.userPassword = password;
    return [QBAuth createSessionWithExtendedRequest:extendedAuthRequest
                                           delegate:[QBEchoObject instance]
                                            context:[QBEchoObject makeBlockForEchoObject:completion]];
}


- (NSObject<Cancelable> *)logInWithEmail:(NSString *)email password:(NSString *)password completion:(QBUUserLogInResultBlock)completion {
    return [QBUsers logInWithUserEmail:email password:password delegate:[QBEchoObject instance] context:[QBEchoObject makeBlockForEchoObject:completion]];
}

- (NSObject<Cancelable> *)createQBAsessionAndlogInWithFacebookAccessToken:(NSString *)accessToken
                                                               completion:(QBAAuthSessionCreationResultBlock)completion {
    
    QBASessionCreationRequest *extendedAuthRequest = [QBASessionCreationRequest request];
    extendedAuthRequest.socialProviderAccessToken = accessToken;
    return [QBAuth createSessionWithExtendedRequest:extendedAuthRequest
                                           delegate:[QBEchoObject instance]
                                            context:[QBEchoObject makeBlockForEchoObject:completion]];
}

- (NSObject<Cancelable> *)logInWithFacebookAccessToken:(NSString *)accessToken completion:(QBUUserLogInResultBlock)completion {
    
    QBUUserLogInResultBlock resultBlock =^ (QBUUserLogInResult *result) {
        result.user.password = [QBBaseModule sharedModule].token;
        completion(result);
    };
    
    return [QBUsers logInWithSocialProvider:kFacebook
                                accessToken:accessToken
                          accessTokenSecret:nil
                                   delegate:[QBEchoObject instance]
                                    context:[QBEchoObject makeBlockForEchoObject:resultBlock]];
}

#pragma mark - Push Notifications

- (NSObject<Cancelable> *)subscribeToPushNotifications:(QBMRegisterSubscriptionTaskResultBlock)competion {
    return [QBMessages TRegisterSubscriptionWithDelegate:[QBEchoObject instance] context:[QBEchoObject makeBlockForEchoObject:competion]];
}

- (NSObject<Cancelable> *)unSubscribeFromPushNotifications:(QBMUnregisterSubscriptionTaskResultBlock)competion {
    return [QBMessages TUnregisterSubscriptionWithDelegate:[QBEchoObject instance] context:[QBEchoObject makeBlockForEchoObject:competion]];
}

@end
