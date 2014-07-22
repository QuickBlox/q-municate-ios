//
//  QBAuthService.h
//  Q-municate
//
//  Created by Igor Alefirenko on 13/02/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QMAuthService : NSObject

#pragma mark - Authorization

/**
 Session Creation
 Type of Result - QBAAuthSessionCreationResult.
 */
- (NSObject<Cancelable> *)createSessionWithBlock:(QBAAuthSessionCreationResultBlock)block;

/**
 User sign up
 Type of Result - QBUUserResult
 @param user An instance of QBUUser, describing the user to be created.
 */
- (NSObject<Cancelable> *)signUpUser:(QBUUser *)user completion:(QBUUserResultBlock)completion;

/**
 Session Destroy
 Type of Result - QBAAuthResult.
  */
- (NSObject<Cancelable> *)destroySessionWithCompletion:(QBAAuthResultBlock)completion;

/**
 User LogIn with email
 Type of Result - QBUUserLogInResult
 @param email Email of QBUUser which authenticates.
 @param password Password of QBUUser which authenticates.
 */
- (NSObject<Cancelable> *)logInWithEmail:(NSString *)email password:(NSString *)password completion:(QBUUserLogInResultBlock)completion;

/**
 User LogIn with social provider's token
 Type of Result - QBUUserLogInResult
 @param accessToken Social provider access token.
 */
- (NSObject<Cancelable> *)logInWithFacebookAccessToken:(NSString *)accessToken completion:(QBUUserLogInResultBlock)completion;

/** Create subscription for current device.
 
 This method registers push token on the server if they are not registered yet, then creates a Subscription and associates it with curent User.
 
 Type of Result - QBMRegisterSubscriptionTaskResult
 
 @param  finish of the request, result will be an instance of QBMRegisterSubscriptionTaskResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
- (NSObject<Cancelable> *)subscribeToPushNotifications:(QBMRegisterSubscriptionTaskResultBlock)competion;
/** Remove subscription for current device.
 
 This method remove subscription for current device from server.
 
 Type of Result - QBMUnregisterSubscriptionTaskResult
 
 @param finish of the request, result will be an instance of QBMUnregisterSubscriptionTaskResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
- (NSObject<Cancelable> *)unSubscribeFromPushNotifications:(QBMUnregisterSubscriptionTaskResultBlock)competion;

@end
