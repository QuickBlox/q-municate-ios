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
#import "QMChatService.h"
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
        NSError *error = [NSError errorWithDomain:[NSString stringWithFormat:@"%@",[result.errors lastObject]] code:0 userInfo:nil];
        resultBlock(nil,NO,error);
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
            resultBlock(nil, NO, result.errors[0]);
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
		NSError *completionError = nil;
		if (![result.errors count]) {
		    completionError = [NSError errorWithDomain:NSNetServicesErrorDomain code:701 userInfo:@{NSLocalizedDescriptionKey : @"Logging in with FBAccessToken. result.errors[0] is empty. Refer to [QMAuthService logInWithFacebookAccessToken:completion:]"}];
		} else {
			completionError = result.errors[0];
		}
        block(nil, NO, completionError);//TODO:fix for crash
    }];
}

- (void)resetUserPasswordForEmail:(NSString *)email completion:(QBResultBlock)block
{
    _resultBlock = block;
    [QBUsers resetUserPasswordWithEmail:email delegate:self];
}

// **************************FACEBOOK**********************************
- (void)authWithFacebookAndCompletionHandler:(QBAuthResultBlock)resultBlock
{
    [FBSession setActiveSession:[[FBSession alloc]initWithPermissions:@[@"basic_info", @"email"]]];
    
    if ([FBSession activeSession].state == FBSessionStateCreated) {
        [[FBSession activeSession] openWithBehavior:FBSessionLoginBehaviorForcingWebView completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
            if (status == FBSessionStateClosedLoginFailed) {
                NSError *error = [NSError errorWithDomain:@"Failed login to Facebook:Canceled" code:10 userInfo:nil];
                resultBlock(nil, NO, error);
                return;
            }
            if (status == FBSessionStateOpen) {
                 NSString *token = session.accessTokenData.accessToken;
                // request me from Facebook:
                QMFacebookService *facebookService = [[QMFacebookService alloc] init];
                [facebookService loadMeWithCompletion:^(NSData *data, NSError *error) {
                    if (error) {
                        return;
                    }
                    NSDictionary *me = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                    [QMContactList shared].facebookMe = [me mutableCopy];
                    
                    // login to Quickblox
                    [self logInWithFacebookAccessToken:token completion:^(QBUUser *user, BOOL success, NSError *error) {
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
            // request me from Facebook:
            QMFacebookService *facebookService = [[QMFacebookService alloc] init];
            [facebookService loadMeWithCompletion:^(NSData *data, NSError *error) {
                if (error) {
                    return;
                }
                NSDictionary *me = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                [QMContactList shared].facebookMe = [me mutableCopy];
                
                NSString *token = [FBSession activeSession].accessTokenData.accessToken;
                [self logInWithFacebookAccessToken:token completion:^(QBUUser *user, BOOL success, NSError *error) {
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


#pragma mark -
#pragma mark QBActionStatusDelegate

-(void)completedWithResult:(Result *)result
{
    if (result.success) {
        if ([result isKindOfClass:[QBAAuthSessionCreationResult class]]) {
            [QMAuthService shared].isSessionCreated = YES;
        } else if ([result.answer isKindOfClass:[QBAAuthSessionDestroyAnswer class]]) {
            [QMAuthService shared].isSessionCreated = NO;
        }
    }
    if (_resultBlock == nil) {
        ILog(@"block == nil, result: %@", result);
        return;
    }
    _resultBlock(result);
}


#pragma mark - Options

- (void)loadFacebookUserPhotoAndUpdateUser:(QBUUser *)user completion:(QBChatResultBlock)handler
{
    // upload photo:
    QMFacebookService *facebookService = [[QMFacebookService alloc] init];
    [facebookService loadAvatarImageFromFacebookWithCompletion:^(NSData *data, NSError *error) {
        if (error) {
            [[[UIAlertView alloc] initWithTitle:kAlertTitleErrorString message:error.localizedDescription delegate:nil cancelButtonTitle:kAlertButtonTitleOkString otherButtonTitles:nil] show];
            return;
        }
        UIImage *avatarImage = [UIImage imageWithData:data];
        
        // load image to Quickblox:
        QMContent *contentStorage = [[QMContent alloc] init];
        [contentStorage loadImageForBlob:avatarImage named:[QMContactList shared].facebookMe[kId] completion:^(QBCBlob *blob) {
            if (blob != nil) {
                // check user email field:
                if (user.email == nil || [user.email isEqualToString:kEmptyString]) {
                    NSString *email = [QMContactList shared].facebookMe[kEmail];
                    user.email = email;
                }
                
                // update user with new blob:
                NSString *userPassword = user.password;
                [[QMAuthService shared] updateUser:user withBlob:blob completion:^(QBUUser *user, BOOL success, NSError *error) {
                    if (success) {
                        user.password = userPassword;
                        [[QMContactList shared] setMe:user];
                        handler(YES);
                    }
                }];
            }
        }];
        
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

@end
