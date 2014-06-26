//
//  QBAuthService.m
//  Q-municate
//
//  Created by Igor Alefirenko on 13/02/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMAuthService.h"
#import "QMFacebookService.h"
#import "QMContactList.h"
//#import "QMChatService.h"
#import "QMUtilities.h"
#import "QMContent.h"


@interface QMAuthService () <QBActionStatusDelegate>

@property (copy, nonatomic) QBResultBlock resultBlock;

@end


@implementation QMAuthService

+ (instancetype)shared
{
    static id authInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        authInstance = [[self alloc] init];
    });
    return authInstance;
}


#pragma mark -
#pragma mark - Authorization

- (void)signUpWithFullName:(NSString *)fullName email:(NSString *)email password:(NSString *)password blobID:(NSUInteger)blobID completion:(QBAuthResultBlock)resultBlock
{
    QBUUser *newUser = [QBUUser user];
    newUser.fullName = fullName;
    newUser.email = email;
    newUser.password = password;
    newUser.blobID = blobID;
    
    [self signUpNewUser:newUser completionHandler:^(Result *result) {
        if (result.success && [result isKindOfClass:[QBUUserResult class]]) {
            QBUUserResult *userResult = (QBUUserResult *)result;
            QBUUser *user = userResult.user;
            resultBlock(user, YES, nil);
            return;
        }
        resultBlock(nil, NO, result.errors.firstObject);
    }];
}

- (void)destroySessionWithCompletion:(QBChatResultBlock)block
{
    [self destroySession:^(Result *result) {
        if (result.success && [result isKindOfClass:[QBAAuthResult class]]) {
            block(YES);
            return;
        }
        block(NO);
    }];
}

- (void)logInWithEmail:(NSString *)email password:(NSString *)password completion:(QBAuthResultBlock)resultBlock
{
    [self logInWithUserEmail:email password:password completionHandler:^(Result *result) {
        if (result.success && [result isKindOfClass:[QBUUserLogInResult class]]) {
            // save me:
            QBUUser *user = ((QBUUserLogInResult *)result).user;
            resultBlock(user, YES, nil);
        } else {
            resultBlock(nil, NO, result.errors.firstObject);
        }
    }];
}

- (void)logInWithFacebookAccessToken:(NSString *)accessToken completion:(QBAuthResultBlock)block
{
    [self logInWithSocialProvider:kFacebook accessToken:accessToken usingBlock:^(Result *result) {
        if (result.success && [result isKindOfClass:[QBUUserLogInResult class]]) {
            QBUUser *user = ((QBUUserLogInResult *)result).user;
            user.password = [QBBaseModule sharedModule].token;
            block(user, YES, nil);
            return;
        }
        block(nil, NO, result.errors.firstObject);
    }];
}

- (void)resetUserPasswordForEmail:(NSString *)email completion:(QBResultBlock)block
{
    _resultBlock = block;
    [QBUsers resetUserPasswordWithEmail:email delegate:self];
}

// **************************FACEBOOK**********************************
- (void)authWithFacebookAndCompletionHandler:(QBAuthResultBlock)resultBlock {
    
	if (![FBSession activeSession] || ![[FBSession activeSession].permissions count] || ![FBSession activeSession].isOpen) {
		[FBSession setActiveSession:[[FBSession alloc]initWithPermissions:@[@"basic_info", @"email", @"read_stream", @"publish_stream"]]];
	}
    
    if ([FBSession activeSession].state == FBSessionStateCreated) {
        
        [[FBSession activeSession] openWithBehavior:FBSessionLoginBehaviorWithFallbackToWebView completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
            
            if (status == FBSessionStateClosedLoginFailed) {
				[FBSession setActiveSession:nil];
                resultBlock(nil, NO, @"Failed login to Facebook:Canceled");
                return;
            }
            
            if (status == FBSessionStateClosed) {
                return;
            }
            
            if (status == FBSessionStateOpen) {
                
                NSString *token = session.accessTokenData.accessToken;
                // request me from Facebook:
                QMFacebookService *facebookService = [[QMFacebookService alloc] init];
                
                [facebookService loadMeWithCompletion:^(NSDictionary *content, NSError *error) {
                    
                    if (error) {
                        return;
                    }
                    
                    [QMContactList shared].fbMe = content.mutableCopy;
                    
                    // login to Quickblox
                    [self logInWithFacebookAccessToken:token completion:^(QBUUser *user, BOOL success, NSString *error) {
                        
                        if (success) {
                            resultBlock(user, success, nil);
                            return;
                        }
                        
                        resultBlock(nil, success, error);
                    }];
                }];
            }
        }];
    } else if ([FBSession activeSession].state == FBSessionStateCreatedTokenLoaded) {
        
        [[FBSession activeSession] openWithCompletionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
            if (status == FBSessionStateClosed) {
                return;
            }
            
            // request me from Facebook:
            QMFacebookService *facebookService = [[QMFacebookService alloc] init];
            
            [facebookService loadMeWithCompletion:^(NSDictionary *content, NSError *error) {
                
                if (error) {
                    resultBlock(nil, NO, error.localizedDescription);
                    return;
                }
                
                [QMContactList shared].fbMe = content.mutableCopy;
                
                NSString *token = [FBSession activeSession].accessTokenData.accessToken;
                [self logInWithFacebookAccessToken:token completion:^(QBUUser *user, BOOL success, NSString *error) {
                    
                    if (success) {
                        resultBlock(user, YES, nil);
                        return;
                    }
                    
                    resultBlock(nil, success, error);
                }];
            }];
        }];
    }
}

- (void)updateUser:(QBUUser *)user withBlob:(QBCBlob *)blob completion:(QBAuthResultBlock)block
{
    user.oldPassword = user.password;
    [self updateUser:user withBlob:blob completionHandler:^(Result *result) {
        if (result.success && [result isKindOfClass:[QBUUserResult class]]) {
            QBUUser *me = ((QBUUserResult *)result).user;
            [QMContactList shared].me = me;
            block(me, YES, nil);
        } else {
            block(nil, NO, result.errors[0]);
        }
    }];
}

- (void)updateUser:(QBUUser *)user withCompletion:(QBAuthResultBlock)block
{
    [self updateUser:user resultBlock:^(Result *result) {
        
        if (result.success && [result isKindOfClass:[QBUUserResult class]]) {
            QBUUser *updatedUser = ((QBUUserResult *)result).user;
            block(updatedUser, YES, nil);
            return;
        }
        
        block(nil, NO, [result.errors firstObject]);
    }];
}


#pragma mark -
#pragma mark - Quickblox API on blocks

- (void)createSessionUsingBlock:(QBResultBlock)result
{
    _resultBlock = result;
    [QBAuth createSessionWithDelegate:self];
}

- (void)destroySession:(QBResultBlock)result
{
    _resultBlock = result;
    [QBAuth destroySessionWithDelegate:self];
}

- (void)signUpNewUser:(QBUUser *)user completionHandler:(QBResultBlock)result
{
    _resultBlock = result;
    [QBUsers signUp:user delegate:self];
}

- (void)logInWithUserEmail:(NSString *)email password:(NSString *)password completionHandler:(QBResultBlock)resultBlock
{
    _resultBlock = resultBlock;
    [QBUsers logInWithUserEmail:email password:password delegate:self];
}

- (void)logInWithSocialProvider:(NSString *)socialProvider accessToken:(NSString *)accessToken usingBlock:(QBResultBlock)resultBlock
{
    _resultBlock = resultBlock;
    [QBUsers logInWithSocialProvider:socialProvider accessToken:accessToken accessTokenSecret:nil delegate:self];
}

- (void)updateUser:(QBUUser *)user withBlob:(QBCBlob *)blob completionHandler:(QBResultBlock)resultBlock
{
    if (blob != nil) {
        user.blobID = blob.ID;
    }
    user.website = [blob publicUrl];
    _resultBlock = resultBlock;
    [QBUsers updateUser:user delegate:self];
}

- (void)updateUser:(QBUUser *)user resultBlock:(QBResultBlock)block
{
    _resultBlock = [block copy];
    [QBUsers updateUser:user delegate:self];
}

- (void)startSessionWithBlock:(QBSessionCreationBlock)block
{
    [[QMAuthService shared] createSessionUsingBlock:^(Result *result) {
        if (result.success && [result isKindOfClass:[QBAAuthSessionCreationResult class]]) {
            block(YES, nil);
        } else {
            block(NO, result.errors[0]);
        }
    }];
}

#pragma mark - Options

- (void)loadFacebookUserPhotoAndUpdateUser:(QBUUser *)user completion:(QBChatResultBlock)handler
{
    // upload photo:
    QMFacebookService *facebookService = [[QMFacebookService alloc] init];
    
    NSString *fbUserID = [QMContactList shared].fbMe.id;
    
    [facebookService loadUserImageFromFacebookWithUserID:fbUserID completion:^(UIImage *img) {
        
        if (img) {
            
            QMContent *contentStorage = [[QMContent alloc] init];
            [contentStorage loadImageForBlob:img named:[QMContactList shared].fbMe.id completion:^(QBCBlob *blob) {
                if (blob) {
                    // update user with new blob:
                    NSString *userPassword = user.password;

                    [[QMAuthService shared] updateUser:user withBlob:blob completion:^(QBUUser *user, BOOL success, NSString *error) {
                        
                        if (success) {
                            user.password = userPassword;
                            if (user.email == nil || [user.email isEqualToString:kEmptyString]) {
                                NSString *email = [QMContactList shared].fbMe[@"mail"];
                                user.email = email;
                            }
                            [[QMContactList shared] setMe:user];
                            handler(YES);
                        }
                    }];
                }
            }];
            
        }
        
    }];
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

-(void)completedWithResult:(Result *)result
{
    if (result.success) {
        if ([result isKindOfClass:[QBAAuthSessionCreationResult class]]) {
            [QMAuthService shared].isSessionCreated = YES;
        } else if ([result.answer isKindOfClass:[QBAAuthSessionDestroyAnswer class]]) {
            [QMAuthService shared].isSessionCreated = NO;
        } else if ([result isKindOfClass:QBMRegisterSubscriptionTaskResult.class]) {
            return;
        }
    }
    if (_resultBlock == nil) {
        ILog(@"block == nil, result: %@", result);
        return;
    }
    _resultBlock(result);
}

//- (void)completedWithResult:(Result *)result context:(void *)contextInfo
//{
//    ((__bridge void (^)(Result * result))(contextInfo))(result);
//    Block_release(contextInfo);
//}

@end
