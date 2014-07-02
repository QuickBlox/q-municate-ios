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

// sign up
- (void)signUpUser:(QBUUser *)user completion:(QBUUserResultBlock)completion;
// destroy session
- (void)destroySessionWithCompletion:(QBAAuthResultBlock)completion;

// log in
- (void)logInWithEmail:(NSString *)email password:(NSString *)password completion:(QBUUserLogInResultBlock)completion;

- (void)logInWithFacebookAccessToken:(NSString *)accessToken completion:(QBUUserLogInResultBlock)completion;

// forgot password
- (void)resetUserPasswordForEmail:(NSString *)email completion:(QBResultBlock)completion;

// update user with blobID
- (void)updateUser:(QBUUser *)user withCompletion:(QBUUserResultBlock)completion;

- (void)startSessionWithBlock:(QBAAuthSessionCreationResultBlock)block;

- (void)subscribeToPushNotifications;
- (void)unSubscribeFromPushNotifications;

@end
