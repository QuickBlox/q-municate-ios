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
#import "QMContent.h"
#import <DigitsKit/DigitsKit.h>

static const NSUInteger kQMDialogsPageLimit = 10;

@implementation QMTasks

#pragma mark - User management

+ (BFTask *)taskUpdateCurrentUser:(QBUpdateUserParameters *)updateParameters {
    
    BFTaskCompletionSource* source = [BFTaskCompletionSource taskCompletionSource];
    
    [QBRequest updateCurrentUser:updateParameters successBlock:^(QBResponse * _Nonnull __unused response, QBUUser * _Nullable user) {
        
        user.password = updateParameters.password ?: [QMCore instance].currentProfile.userData.password;
        [[QMCore instance].currentProfile synchronizeWithUserData:user];
        
        [source setResult:user];
        
    } errorBlock:^(QBResponse * _Nonnull response) {
        
        [[QMCore instance] handleErrorResponse:response];
        [source setError:response.error.error];
    }];
    
    return source.task;
}

+ (BFTask *)taskUpdateCurrentUserImage:(UIImage *)userImage progress:(QMContentProgressBlock)progress {
    
    return [[QMContent uploadJPEGImage:userImage progress:progress] continueWithSuccessBlock:^id _Nullable(BFTask<QBCBlob *> * _Nonnull task) {
        
        QBUpdateUserParameters *userParams = [QBUpdateUserParameters new];
        userParams.customData = [QMCore instance].currentProfile.userData.customData;
        userParams.avatarUrl = task.result.isPublic ? [task.result publicUrl] : [task.result privateUrl];
        
        return [[self class] taskUpdateCurrentUser:userParams];
    }];
}

+ (BFTask *)taskResetPasswordForEmail:(NSString *)email {
    
    BFTaskCompletionSource* source = [BFTaskCompletionSource taskCompletionSource];
    
    [QBRequest resetUserPasswordWithEmail:email successBlock:^(QBResponse * _Nonnull __unused response) {
        
        [source setResult:nil];
        
    } errorBlock:^(QBResponse * _Nonnull response) {
        
        [source setError:response.error.error];
    }];
    
    return source.task;
}

#pragma mark - Data tasks

+ (BFTask *)taskAutoLogin {
    
    BFTaskCompletionSource* source = [BFTaskCompletionSource taskCompletionSource];
    
    if ([QMCore instance].currentProfile.userData == nil) {
        [source setError:[QMErrorsFactory errorNotLoggedInREST]];
        
        return source.task;
    }
    
    if ([[QMCore instance] isAuthorized]) {
        
        [source setResult:[QMCore instance].currentProfile.userData];
    }
    else {
        
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
                
                DGTOAuthSigning *oauthSigning = [[DGTOAuthSigning alloc]
                                                 initWithAuthConfig:[Digits sharedInstance].authConfig
                                                 authSession:[[Digits sharedInstance] session]];
                
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
    
    NSMutableArray *usersLoadingTasks = [NSMutableArray array];
    
    __block void (^iterationBlock)(QBResponse *, NSArray *, NSSet *, BOOL *) = ^(QBResponse *__unused response, NSArray *__unused dialogObjects, NSSet *dialogsUsersIDs, BOOL *__unused stop) {
        
        [usersLoadingTasks addObject:[[QMCore instance].usersService getUsersWithIDs:dialogsUsersIDs.allObjects]];
    };
    
    __block BFContinuationBlock completionBlock = ^id _Nullable(BFTask * _Nonnull task) {
        
        if ([[QMCore instance] isAuthorized] && !task.isFaulted) {
            
            [QMCore instance].currentProfile.lastDialogsFetchingDate = [NSDate date];
            [[QMCore instance].currentProfile synchronize];
        }
        
        return [BFTask taskForCompletionOfAllTasks:[usersLoadingTasks copy]];
    };
    
    NSDate *lastDialogsFetchingDate = [QMCore instance].currentProfile.lastDialogsFetchingDate;
    if (lastDialogsFetchingDate != nil) {
        
        return [[[QMCore instance].chatService fetchDialogsUpdatedFromDate:lastDialogsFetchingDate andPageLimit:kQMDialogsPageLimit iterationBlock:^(QBResponse * _Nonnull response, NSArray<QBChatDialog *> * _Nullable dialogObjects, NSSet<NSNumber *> * _Nullable dialogsUsersIDs, BOOL * _Nonnull stop) {
            
            iterationBlock(response, dialogObjects, dialogsUsersIDs, stop);
            
        }] continueWithBlock:^id _Nullable(BFTask * _Nonnull t) {
            
            completionBlock(t);
            completionBlock = nil;
            iterationBlock = nil;
            return nil;
        }];
    }
    else {
        
        return [[[QMCore instance].chatService allDialogsWithPageLimit:kQMDialogsPageLimit extendedRequest:nil iterationBlock:^(QBResponse * _Nonnull response, NSArray<QBChatDialog *> * _Nullable dialogObjects, NSSet<NSNumber *> * _Nullable dialogsUsersIDs, BOOL * _Nonnull stop) {
            
            iterationBlock(response, dialogObjects, dialogsUsersIDs, stop);
            
        }] continueWithBlock:^id _Nullable(BFTask * _Nonnull t) {
            
            completionBlock(t);
            completionBlock = nil;
            iterationBlock = nil;
            return nil;
        }];
    }
}

+ (BFTask *)taskUpdateContacts {
    
    NSArray *contactsIDs = [[QMCore instance].contactListService.contactListMemoryStorage userIDsFromContactList];
    
    return [[QMCore instance].usersService getUsersWithIDs:contactsIDs forceLoad:YES];
}

@end
