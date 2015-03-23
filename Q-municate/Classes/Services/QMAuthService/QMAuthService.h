//
//  QBAuthService.h
//  Q-municate
//
//  Created by Ivanov Andrey Ivanov on 13/07/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QMBaseService.h"

typedef void (^QBUUserResultBlock)(QBUUserResult *result);

@interface QMAuthService : QMBaseService

#pragma mark - Authorization

/**
 Result YES if session token has expired or need create new session
 */
- (BOOL)sessionTokenHasExpiredOrNeedCreate;


/**
 User sign up
 Type of Result - QBUUserResult
 
 @param user An instance of QBUUser, describing the user to be created.
 */
- (NSObject<Cancelable> *)signUpUser:(QBUUser *)user completion:(QBUUserResultBlock)completion;

/**
 User LogIn with email
 Type of Result - QBUUserLogInResult
 
 @param email Email of QBUUser which authenticates.
 @param password Password of QBUUser which authenticates.
 */

- (NSObject<Cancelable> *)createQBAsessionAndAogInWithEmail:(NSString *)email password:(NSString *)password completion:(QBAAuthSessionCreationResultBlock)completion;

/**
 Session Creation and User LogIn with email and password
 Type of Result - QBAAuthSessionCreationResult
 
 @param email Email of QBUUser which authenticates.
 @param password Password of QBUUser which authenticates.
 */
- (NSObject<Cancelable> *)logInWithEmail:(NSString *)email password:(NSString *)password completion:(QBUUserLogInResultBlock)completion;

/**
 Session Creation and User LogIn with social provider's token
 Type of Result - QBAAuthSessionCreationResult.
 
 @param extendedRequest Extended set of request parameters
 @param finish of the request, result will be an instance of QBAAuthSessionCreationResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */

- (NSObject<Cancelable> *)createQBAsessionAndlogInWithFacebookAccessToken:(NSString *)accessToken completion:(QBAAuthSessionCreationResultBlock)completion;

/**
 User LogIn with social provider's token
 Type of Result - QBAAuthSessionCreationResult
 
 @param accessToken Facebook access token.
 */
- (NSObject<Cancelable> *)logInWithFacebookAccessToken:(NSString *)accessToken completion:(QBUUserLogInResultBlock)completion;

@end
