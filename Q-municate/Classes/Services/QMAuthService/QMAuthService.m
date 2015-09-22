//
//  QBAuthService.m
//  Q-municate
//
//  Created by Ivanov Andrey Ivanov on 13/07/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMAuthService.h"

@implementation QMAuthService


#pragma mark Create/Destroy Quickblox Sesson

- (void)start {
    [super start];
}

- (void)stop {
    [super stop];
}

- (BOOL)sessionTokenHasExpiredOrNeedCreate {
    
    NSDate *sessionExpiratioDate = [QBSession currentSession].sessionExpirationDate;
    NSDate *currentDate = [NSDate date];
    NSTimeInterval interval = [currentDate timeIntervalSinceDate:sessionExpiratioDate];
    if(interval > 0 || isnan(interval)){
        // recreate session here
        return YES;
    }
    return NO;
}


#pragma mark - Authorization

- (QBRequest *)signUpUser:(QBUUser *)user completion:(QBUUserResponseBlock)completion {
    
    return [QBRequest signUp:user successBlock:^(QBResponse *response, QBUUser *createdUser) {
        //
        completion(response,createdUser);
    } errorBlock:^(QBResponse *response) {
        //
        completion(response,nil);
    }];
}

- (QBRequest *)logInWithEmail:(NSString *)email password:(NSString *)password completion:(QBUUserLogInResponseBlock)completion {
    return [QBRequest logInWithUserEmail:email password:password successBlock:^(QBResponse *response, QBUUser *user) {
        //
        completion(response,user);
    } errorBlock:^(QBResponse *response) {
        //
        completion(response,nil);
    }];
}

- (QBRequest *)logInWithFacebookAccessToken:(NSString *)accessToken completion:(QBUUserLogInResponseBlock)completion {
    
    return [QBRequest logInWithSocialProvider:@"facebook" accessToken:accessToken accessTokenSecret:nil successBlock:^(QBResponse *response, QBUUser *user) {
        //
        user.password = [FBSession activeSession].accessTokenData.accessToken;
        completion(response,user);
    } errorBlock:^(QBResponse *response) {
        //
        completion(response,nil);
    }];
}

@end
