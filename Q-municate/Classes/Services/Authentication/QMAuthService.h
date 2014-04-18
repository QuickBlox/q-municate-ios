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
// create session
- (void)createSessionUsingBlock:(QBResultBlock)result;

// destroy session
- (void)destroySessionWithCompletion:(QBChatResultBlock)block;

// sign up
- (void)signUpWithFullName:(NSString *)fullName email:(NSString *)email password:(NSString *)password blobID:(NSUInteger)blobID completion:(QBAuthResultBlock)resultBlock;

// log in
- (void)logInWithEmail:(NSString *)email password:(NSString *)password completion:(QBAuthResultBlock)resultBlock;
- (void)logInWithFacebookAccessToken:(NSString *)accessToken completion:(QBAuthResultBlock)block;
- (void)authWithFacebookAndCompletionHandler:(QBAuthResultBlock)resultBlock;

// forgot password
- (void)resetUserPasswordForEmail:(NSString *)email completion:(QBResultBlock)block;

// update user with blobID
- (void)updateUser:(QBUUser *)user withBlob:(QBCBlob *)blob completion:(QBAuthResultBlock)block;
- (void)updateUser:(QBUUser *)user withCompletion:(QBAuthResultBlock)block;

- (void)startSessionWithBlock:(QBSessionCreationBlock)block;

#pragma mark - Options
- (void)loadFacebookUserPhotoAndUpdateUser:(QBUUser *)user completion:(QBChatResultBlock)handler;

- (void)subscribeToPushNotifications;

- (void)unSubscribeFromPushNotifications;
@end
