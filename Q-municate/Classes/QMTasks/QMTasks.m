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

#import <FirebaseCore/FirebaseCore.h>
#import <FirebaseAuth/FirebaseAuth.h>
#import <Bolts/Bolts.h>

static const NSUInteger kQMDialogsPageLimit = 100;
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
    QBUUser *currentProfile = [core.currentProfile.userData copy];
    
    if (currentProfile == nil) {
        
        NSError *error = [QMErrorsFactory errorNotLoggedInREST];
        return [BFTask taskWithError:error];
    }
    
    const QMAccountType type = core.currentProfile.accountType;
    
    if (core.isAuthorized) {
        
        switch (type) {
            case QMAccountTypeEmail:
                return [BFTask taskWithResult:currentProfile];
                
            case QMAccountTypePhone: {
                FIRUser *phoneUser = [[FIRAuth auth] currentUser];
                if (phoneUser == nil) {
                    NSError *error = [QMErrorsFactory errorNotLoggedInREST];
                    return [BFTask taskWithError:error];
                }
            }
            case QMAccountTypeFacebook:
                currentProfile.password = QBSession.currentSession.sessionDetails.token;
                return [BFTask taskWithResult:currentProfile];
                
            case QMAccountTypeNone: {
                NSError *error = [QMErrorsFactory errorNotLoggedInREST];
                return [BFTask taskWithError:error];
            }
        }
    }
    
    if (type == QMAccountTypeEmail) {
        
        return [core.authService loginWithUser:currentProfile];
    }
    else if (type == QMAccountTypeFacebook) {
        
        return [[QMFacebook connect] continueWithSuccessBlock:^id(BFTask<NSString *> *task) {
            return [core.authService loginWithFacebookSessionToken:task.result];
        }];
    }
    else if (type == QMAccountTypePhone) {
        
        BFTaskCompletionSource *source =
        [BFTaskCompletionSource taskCompletionSource];
        
        FIRAuth *auth = [FIRAuth auth];
        FIRUser *phoneUser = [[FIRAuth auth] currentUser];
        if (phoneUser) {
            [phoneUser getIDTokenWithCompletion:^(NSString * _Nullable token, NSError * _Nullable error) {
                if (error) {
                    [source setError:error];
                    return;
                }
                
                [[[QMCore instance].authService logInWithFirebaseProjectID:auth.app.options.projectID accessToken:token] continueWithBlock:^id _Nullable(BFTask<QBUUser *> * _Nonnull t) {
                    t.isFaulted ? [source setError:t.error] : [source setResult:t.result];
                    return nil;
                }];
            }];
        }
        else {
            NSError *error = [QMErrorsFactory errorNotLoggedInREST];
            [source setError:error];
        }
        
        return source.task;
    }
    else {
        
        NSError *error = [QMErrorsFactory errorNotLoggedInREST];
        return [BFTask taskWithError:error];
    }
}

+ (BFTask *)taskFetchAllData {
    
    NSMutableArray<BFTask<NSArray<QBUUser *>*>*> *usersLoadingTasks = [NSMutableArray array];
    
    QMCore *core = QMCore.instance;
    
    void (^iterationBlock)(QBResponse *, NSArray *, NSSet *, BOOL *) =
    ^(QBResponse *__unused response, NSArray *__unused dialogObjects, NSSet *dialogsUsersIDs, BOOL *__unused stop) {
        
        if (dialogsUsersIDs.count > 0) {
            
            [self sliceArray:dialogsUsersIDs.allObjects
                       limit:kQMUsersPageLimit
                   enumerate:^(NSArray *slice, NSRange __unused range)
             {
                 BFTask<NSArray<QBUUser *> *> *task = [core.usersService getUsersWithIDs:slice];
                 [usersLoadingTasks addObject:task];
             }];
        }
    };
    
    BFContinuationBlock completionBlock = ^id _Nullable(BFTask *task) {
        
        if (core.currentProfile.userData && !task.isFaulted) {
            
            core.currentProfile.lastDialogsFetchingDate = [NSDate date];
            [core.currentProfile synchronize];
        }
        else {
            return nil;
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
    
    [self sliceArray:contactsIDs
               limit:kQMUsersPageLimit
           enumerate:^(NSArray *slice, NSRange range)
     {
         QBGeneralResponsePage *page =
         [QBGeneralResponsePage responsePageWithCurrentPage:1
                                                    perPage:range.length];
         BFTask *task =
         [core.usersService searchUsersWithExtendedRequest:filterForUsersFetch(slice, dateFilter)
                                                      page:page];
         [tasks addObject:task];
     }];
    
    BFTask *task = [[BFTask taskForCompletionOfAllTasks:[tasks copy]] continueWithSuccessBlock:^id(BFTask * __unused t) {
        core.currentProfile.lastUserFetchDate = [NSDate date];
        [core.currentProfile synchronize];
        return nil;
    }];
    
    return task;
}

+ (void)sliceArray:(NSArray *)array
             limit:(NSUInteger)limit
         enumerate:(void(^)(NSArray *slice, NSRange range))enumerate {
    
    NSRange range = NSMakeRange(0, array.count > limit ? limit : array.count);
    
    while (range.location < array.count) {
        
        NSArray *slice = [array subarrayWithRange:range];
        enumerate(slice, range);
        
        range.location += range.length;
        NSUInteger diff = array.count - range.location;
        range.length = diff > limit ? limit : diff;
    }
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
