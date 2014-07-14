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
- (void)createSessionWithBlock:(QBAAuthSessionCreationResultBlock)block;

/**
 User sign up
 Type of Result - QBUUserResult
 @param user An instance of QBUUser, describing the user to be created.
 */
- (void)signUpUser:(QBUUser *)user completion:(QBUUserResultBlock)completion;

/**
 Session Destroy
 Type of Result - QBAAuthResult.
  */
- (void)destroySessionWithCompletion:(QBAAuthResultBlock)completion;

/**
 User LogIn with email
 Type of Result - QBUUserLogInResult
 @param email Email of QBUUser which authenticates.
 @param password Password of QBUUser which authenticates.
 */
- (void)logInWithEmail:(NSString *)email password:(NSString *)password completion:(QBUUserLogInResultBlock)completion;

/**
 User LogIn with social provider's token
 Type of Result - QBUUserLogInResult
 @param accessToken Social provider access token.
 */
- (void)logInWithFacebookAccessToken:(NSString *)accessToken completion:(QBUUserLogInResultBlock)completion;

/**
 Reset user's password. User with this email will retrieve email instruction for reset password.
 Type of Result - Result
 @param email User's email
 */
- (void)resetUserPasswordWithEmail:(NSString *)email completion:(QBResultBlock)completion;
/**
 Update User
 Type of Result - QBUUserResult
 @param user An instance of QBUUser, describing the user to be edited.
 */
- (void)updateUser:(QBUUser *)user withCompletion:(QBUUserResultBlock)completion;


- (void)subscribeToPushNotifications;
- (void)unSubscribeFromPushNotifications;

@end
