//
//  QMTasks.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 1/8/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMTasks.h"
#import "QMCore.h"
#import "QMErrorsFactory.h"
#import "QMFacebook.h"
#import <DigitsKit/DigitsKit.h>

@implementation QMTasks

+ (BFTask *)taskUpdateCurrentUser:(QBUpdateUserParameters *)updateParameters {
    
    BFTaskCompletionSource* source = [BFTaskCompletionSource taskCompletionSource];
    
    [QBRequest updateCurrentUser:updateParameters successBlock:^(QBResponse * _Nonnull __unused response, QBUUser * _Nullable user) {
        
        [source setResult:user];
    } errorBlock:^(QBResponse * _Nonnull response) {
        
        [source setError:response.error.error];
    }];
    
    return source.task;
}

+ (BFTask *)taskAutoLogin {
    
    BFTaskCompletionSource* source = [BFTaskCompletionSource taskCompletionSource];
    
    if ([QMCore instance].currentProfile.userData == nil) {
        [source setError:[QMErrorsFactory errorNotLoggedInREST]];
        
        return source.task;
    }
    
    if ([QMCore instance].isAuthorized) {
        
        [source setResult:[QMCore instance].currentUser];
    } else {
        
        switch ([QMCore instance].currentProfile.accountType) {
                
                // Email login
            case QMAccountTypeEmail: {
                
                return [[QMCore instance].authService loginWithUser:[QMCore instance].currentProfile.userData];
            }
                break;
                
                // Facebook login
            case QMAccountTypeFacebook: {
                
                return [[QMFacebook connect] continueWithBlock:^id _Nullable(BFTask<NSString *> * _Nonnull task) {
                    
                    return task.result != nil ? [[QMCore instance].authService loginWithFacebookSessionToken:task.result] : nil;
                }];
            }
                break;
                
                // Digits login
            case QMAccountTypeDigits: {
                
                DGTOAuthSigning *oauthSigning = [[DGTOAuthSigning alloc] initWithAuthConfig:[Digits sharedInstance].authConfig
                                                                                authSession:[Digits sharedInstance].session];
                
                NSDictionary *authHeaders = [oauthSigning OAuthEchoHeadersToVerifyCredentials];
                if (!authHeaders) {
                    [source setError:[QMErrorsFactory errorNotLoggedInREST]];
                    break;
                }
                
                return [[QMCore instance].authService loginWithTwitterDigitsAuthHeaders:authHeaders];
            }
                break;
                
            default:
                [source setError:[QMErrorsFactory errorNotLoggedInREST]];
                break;
        }
    }
    
    return source.task;
}

+ (BFTask *)taskFetchAllData {
    
    __block NSMutableArray *usersLoadingTasks = [NSMutableArray array];
    
    void (^iterationBlock)(QBResponse *, NSArray *, NSSet *, BOOL *) = ^(QBResponse *__unused response, NSArray *__unused dialogObjects, NSSet *__unused dialogsUsersIDs, BOOL *__unused stop) {
        
        [usersLoadingTasks addObject:[[QMCore instance].usersService getUsersWithIDs:[dialogsUsersIDs allObjects]]];
    };
    BFContinuationBlock completionBlock = ^id _Nullable(BFTask * _Nonnull task) {
        if ([QMCore instance].isAuthorized && !task.isFaulted) [QMCore instance].lastActivityDate = [NSDate date];
        
        return [BFTask taskForCompletionOfAllTasks:usersLoadingTasks.copy];
    };
    
    if ([QMCore instance].lastActivityDate != nil) {
        return [[[QMCore instance].chatService fetchDialogsUpdatedFromDate:[QMCore instance].lastActivityDate andPageLimit:kQMDialogsPageLimit iterationBlock:iterationBlock] continueWithBlock:completionBlock];
    }
    else {
        return [[[QMCore instance].chatService allDialogsWithPageLimit:kQMDialogsPageLimit extendedRequest:nil iterationBlock:iterationBlock] continueWithBlock:completionBlock];
    }
}

@end
