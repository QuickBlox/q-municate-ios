//
//  QBAuthService.h
//  Q-municate
//
//  Created by Ivanov Andrey Ivanov on 13/07/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QMBaseService.h"

typedef void (^QBUUserResponseBlock)(QBResponse *response, QBUUser *user);

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
- (QBRequest *)signUpUser:(QBUUser *)user completion:(QBUUserResponseBlock)completion;

/**
 Session Creation and User LogIn with email and password
 Type of Result - QBAAuthSessionCreationResult
 
 @param email Email of QBUUser which authenticates.
 @param password Password of QBUUser which authenticates.
 */
- (QBRequest *)logInWithEmail:(NSString *)email password:(NSString *)password completion:(QBUUserLogInResponseBlock)completion;

/**
 User LogIn with social provider's token
 Type of Result - QBAAuthSessionCreationResult
 
 @param accessToken Facebook access token.
 */
- (QBRequest *)logInWithFacebookAccessToken:(NSString *)accessToken completion:(QBUUserLogInResponseBlock)completion;

@end
