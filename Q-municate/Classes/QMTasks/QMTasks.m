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
static const NSUInteger kQMUsersPageLimit = 100;

@implementation QMTasks

//MARK: - User management

+ (BFTask *)taskUpdateCurrentUser:(QBUpdateUserParameters *)updateParameters {
    
    BFTaskCompletionSource* source = [BFTaskCompletionSource taskCompletionSource];
    
    [QBRequest updateCurrentUser:updateParameters successBlock:^(QBResponse * _Nonnull __unused response, QBUUser * _Nullable user) {
        
        user.password = updateParameters.password ?: QMCore.instance.currentProfile.userData.password;
        [QMCore.instance.currentProfile synchronizeWithUserData:user];
        
        [source setResult:user];
        
    } errorBlock:^(QBResponse * _Nonnull response) {
        
        [QMCore.instance handleErrorResponse:response];
        [source setError:response.error.error];
    }];
    
    return source.task;
}

+ (BFTask *)taskUpdateCurrentUserImage:(UIImage *)userImage progress:(QMContentProgressBlock)progress {
    
    return [[QMContent uploadJPEGImage:userImage progress:progress] continueWithSuccessBlock:^id _Nullable(BFTask<QBCBlob *> * _Nonnull task) {
        
        QBUpdateUserParameters *userParams = [QBUpdateUserParameters new];
        userParams.customData = QMCore.instance.currentProfile.userData.customData;
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

//MARK: - Data tasks

+ (BFTask *)taskAutoLogin {
    
    BFTaskCompletionSource* source = [BFTaskCompletionSource taskCompletionSource];
    
    if (QMCore.instance.currentProfile.userData == nil) {
        [source setError:[QMErrorsFactory errorNotLoggedInREST]];
        
        return source.task;
    }
    
    if ([QMCore.instance isAuthorized]) {
        
        [source setResult:QMCore.instance.currentProfile.userData];
    }
    else {
        
        switch (QMCore.instance.currentProfile.accountType) {
                
                // Email login
            case QMAccountTypeEmail: {
                
                return [QMCore.instance.authService loginWithUser:QMCore.instance.currentProfile.userData];
            }
                break;
                
                // Facebook login
            case QMAccountTypeFacebook: {
                
                return [[QMFacebook connect] continueWithBlock:^id _Nullable(BFTask<NSString *> * _Nonnull task) {
                    
                    return task.result != nil ? [QMCore.instance.authService loginWithFacebookSessionToken:task.result] : nil;
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
                
                return [QMCore.instance.authService loginWithTwitterDigitsAuthHeaders:authHeaders];
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
    
    void (^iterationBlock)(QBResponse *, NSArray *, NSSet *, BOOL *) = ^(QBResponse *__unused response, NSArray *__unused dialogObjects, NSSet *dialogsUsersIDs, BOOL *__unused stop) {
        
        [usersLoadingTasks addObject:[QMCore.instance.usersService getUsersWithIDs:dialogsUsersIDs.allObjects]];
    };
    
    BFContinuationBlock completionBlock = ^id _Nullable(BFTask * _Nonnull task) {
        
        if ([QMCore.instance isAuthorized] && !task.isFaulted) {
            
            QMCore.instance.currentProfile.lastDialogsFetchingDate = [NSDate date];
            [QMCore.instance.currentProfile synchronize];
        }
        
        return [BFTask taskForCompletionOfAllTasks:[usersLoadingTasks copy]];
    };
    
    NSDate *lastDialogsFetchingDate = QMCore.instance.currentProfile.lastDialogsFetchingDate;
    if (lastDialogsFetchingDate != nil) {
        
        return [[QMCore.instance.chatService fetchDialogsUpdatedFromDate:lastDialogsFetchingDate andPageLimit:kQMDialogsPageLimit iterationBlock:iterationBlock] continueWithBlock:completionBlock];
    }
    else {
        
        return [[QMCore.instance.chatService allDialogsWithPageLimit:kQMDialogsPageLimit extendedRequest:nil iterationBlock:iterationBlock] continueWithBlock:completionBlock];
    }
}

+ (BFTask *)taskUpdateContacts {
    
    NSDate *lastUserFetchDate = [QMCore instance].currentProfile.lastUserFetchDate;
    NSMutableArray *contactsIDs = [[[QMCore instance].contactListService.contactListMemoryStorage userIDsFromContactList] mutableCopy];
    [contactsIDs addObject:@([QMCore instance].currentProfile.userData.ID)];
    NSString *dateFilter = nil;
    
    if (lastUserFetchDate != nil) {
        static NSDateFormatter *dateFormatter = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZ";
        });
        dateFilter = [[NSString alloc] initWithFormat:@"date updated_at gt %@", [dateFormatter stringFromDate:lastUserFetchDate]];
    }
    
    NSMutableArray *tasks = [[NSMutableArray alloc] init];
    
    NSRange range;
    range.location = 0;
    range.length = contactsIDs.count > kQMUsersPageLimit ? kQMUsersPageLimit : contactsIDs.count;
    
    while (range.location < contactsIDs.count) {
        NSArray *subArray = [contactsIDs subarrayWithRange:range];
        BFTask *task = [[QMCore instance].usersService searchUsersWithExtendedRequest:filterForUsersFetch(subArray, dateFilter)
                                                                                 page:[QBGeneralResponsePage responsePageWithCurrentPage:0
                                                                                                                                 perPage:range.length]];
        [tasks addObject:task];
        
        range.location += range.length;
        NSUInteger diff = contactsIDs.count - range.location;
        range.length = diff > kQMUsersPageLimit ? kQMUsersPageLimit : diff;
    }
    
    BFTask *task = [[BFTask taskForCompletionOfAllTasks:[tasks copy]] continueWithSuccessBlock:^id(BFTask * __unused t) {
        [QMCore instance].currentProfile.lastUserFetchDate = [NSDate date];
        [[QMCore instance].currentProfile synchronize];
        return nil;
    }];
    
    return task;
}

static inline NSDictionary *filterForUsersFetch(NSArray *usersIDs, NSString *dateFilter) {
    NSDictionary *filters = nil;
    NSString *usersString = [usersIDs componentsJoinedByString:@", "];
    if (dateFilter != nil) {
        filters = @{@"filter" : @[
                            [NSString stringWithFormat:@"number id in %@", usersString],
                            [NSString stringWithFormat:@"date updated_at gt %@", dateFilter],
                            ]};
    }
    else {
        filters = @{@"filter" : @[
                            [NSString stringWithFormat:@"number id in %@", usersString],
                            ]};
    }
    return filters;
}

@end
