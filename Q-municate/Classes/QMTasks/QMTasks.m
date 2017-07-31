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
    
    QMCore *core = QMCore.instance;
    QBUUser *user = core.currentProfile.userData;
    
    if (user == nil) {
        
        NSError *error = [QMErrorsFactory errorNotLoggedInREST];
        return [BFTask taskWithError:error];
    }
    
    const QMAccountType type = core.currentProfile.accountType;
    
    if (type == QMAccountTypeEmail) {
        
        if (core.isAuthorized) {
            return [BFTask taskWithResult:user];
        }
        return [core.authService loginWithUser:user];
    }
    else if (type == QMAccountTypeFacebook) {
        
        return [[QMFacebook connect] continueWithBlock:^id(BFTask<NSString *> *task) {
            return task.result ? [core.authService loginWithFacebookSessionToken:task.result] : nil;
        }];
    }
    else if (type == QMAccountTypeDigits) {
        
        Digits *digits = [Digits sharedInstance];
        DGTOAuthSigning *oauthSigning =
        [[DGTOAuthSigning alloc] initWithAuthConfig:digits.authConfig
                                        authSession:[digits session]];
        
        NSDictionary *authHeaders = [oauthSigning OAuthEchoHeadersToVerifyCredentials];
        if (!authHeaders) {
            NSError *error = [QMErrorsFactory errorNotLoggedInREST];
            return [BFTask taskWithError:error];
        }
        
        return [QMCore.instance.authService loginWithTwitterDigitsAuthHeaders:authHeaders];
    }
    else {
        
        NSError *error = [QMErrorsFactory errorNotLoggedInREST];
        return [BFTask taskWithError:error];
    }
}

+ (BFTask *)taskFetchAllData {
    
    NSMutableArray *usersLoadingTasks = [NSMutableArray array];
    
    QMCore *core = QMCore.instance;
    
    void (^iterationBlock)(QBResponse *, NSArray *, NSSet *, BOOL *) =
    ^(QBResponse *__unused response, NSArray *__unused dialogObjects, NSSet *dialogsUsersIDs, BOOL *__unused stop) {
        
        [usersLoadingTasks addObject:[core.usersService getUsersWithIDs:dialogsUsersIDs.allObjects]];
    };
    
    BFContinuationBlock completionBlock = ^id _Nullable(BFTask *task) {
        if (core.isAuthorized && !task.isFaulted) {
            
            core.currentProfile.lastDialogsFetchingDate = [NSDate date];
            [core.currentProfile synchronize];
        }
        
        return [BFTask taskForCompletionOfAllTasks:[usersLoadingTasks copy]];
    };
    
    NSDate *date = core.currentProfile.lastDialogsFetchingDate;
    if (date) {
        
        return [[core.chatService
                 fetchDialogsUpdatedFromDate:date
                 andPageLimit:kQMDialogsPageLimit
                 iterationBlock:iterationBlock] continueWithBlock:completionBlock];
    }
    else {
        
        return [[core.chatService
                 allDialogsWithPageLimit:kQMDialogsPageLimit
                 extendedRequest:nil
                 iterationBlock:iterationBlock] continueWithBlock:completionBlock];
    }
}

+ (BFTask *)taskUpdateContacts {
    
    QMCore *core = QMCore.instance;
    
    NSDate *lastUserFetchDate = core.currentProfile.lastUserFetchDate;
    NSMutableArray *contactsIDs = [[core.contactListService.contactListMemoryStorage userIDsFromContactList] mutableCopy];
    [contactsIDs addObject:@(core.currentProfile.userData.ID)];
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
        QBGeneralResponsePage *page =
        [QBGeneralResponsePage responsePageWithCurrentPage:0 perPage:range.length];
        
        BFTask *task = [core.usersService searchUsersWithExtendedRequest:filterForUsersFetch(subArray, dateFilter)
                                                                    page:page];
        [tasks addObject:task];
        
        range.location += range.length;
        NSUInteger diff = contactsIDs.count - range.location;
        range.length = diff > kQMUsersPageLimit ? kQMUsersPageLimit : diff;
    }
    
    BFTask *task = [[BFTask taskForCompletionOfAllTasks:[tasks copy]] continueWithSuccessBlock:^id(BFTask * __unused t) {
        core.currentProfile.lastUserFetchDate = [NSDate date];
        [core.currentProfile synchronize];
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
