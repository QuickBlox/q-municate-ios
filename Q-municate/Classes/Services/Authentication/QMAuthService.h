//
//  QBAuthService.h
//  Q-municate
//
//  Created by Igor Alefirenko on 13/02/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QMAuthService : NSObject

+ (instancetype)shared;

@property (assign) BOOL isSessionCreated;

#pragma mark - Authorization

// destroy session
- (void)destroySessionWithCompletion:(QBChatResultBlock)completion;

// sign up
- (void)signUpUser:(QBUUser *)user completion:(QBAuthResultBlock)completion;

// log in
- (void)logInWithEmail:(NSString *)email password:(NSString *)password completion:(QBAuthResultBlock)complition;

- (void)logInWithFacebookAccessToken:(NSString *)accessToken completion:(QBAuthResultBlock)completion;

// forgot password
- (void)resetUserPasswordForEmail:(NSString *)email completion:(QBResultBlock)completion;

// update user with blobID
- (void)updateUser:(QBUUser *)user withBlob:(QBCBlob *)blob completion:(QBAuthResultBlock)completion;

- (void)updateUser:(QBUUser *)user withCompletion:(QBAuthResultBlock)completion;

- (void)startSessionWithBlock:(QBSessionCreationBlock)block;

//#pragma mark - Options
//- (void)loadFacebookUserPhotoAndUpdateUser:(QBUUser *)user completion:(QBChatResultBlock)handler;

- (void)subscribeToPushNotifications;

- (void)unSubscribeFromPushNotifications;
@end
