//
//  QMCore.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 1/8/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMCore.h"
#import <Reachability.h>
#import "QMFacebook.h"
#import "QMNotification.h"
#import <DigitsKit/DigitsKit.h>

static NSString *const kQMLastActivityDateKey = @"last_activity_date";
static NSString *const kQMErrorKey = @"errors";
static NSString *const kQMBaseKey = @"base";
static NSString *const kQMErrorEmailKey = @"email";
static NSString *const kQMErrorFullNameKey = @"full_name";
static NSString *const kQMErrorPasswordKey = @"password";

@interface QMCore ()

@property (strong, nonatomic) NSUserDefaults *defaults;

@end

@implementation QMCore

+ (instancetype)instance {
    
    static QMCore *core = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        core = [[self alloc] init];
    });
    
    return core;
}

- (instancetype)init {
    self = [super init];
    
    if (self) {
        // Contact list service init
        [QMContactListCache setupDBWithStoreNamed:kContactListCacheNameKey];
        _contactListService = [[QMContactListService alloc] initWithServiceManager:self cacheDataSource:self];
        [_contactListService addDelegate:self];
        
        // Profile init
        _currentProfile = [QMProfile currentProfile];
        
        // Users cache init
        [self.usersService loadFromCache];
        
        // managers
        _contactManager = [[QMContactManager alloc] initWithServiceManager:self];
        _notificationManager = [[QMNotificationManager alloc] initWithServiceManager:self];
        
        // Reachability init
//        _internetConnection = [Reachability reachabilityForInternetConnection];
        
        _defaults = [NSUserDefaults standardUserDefaults];
    }
    
    return self;
}

#pragma mark - Error handling

- (NSString *)errorStringFromArray:(NSArray *)errorArray {
    NSString *errorString = [[NSString alloc] init];
    
    for (NSUInteger i = 0; i < errorArray.count; ++i) {
        if (i > 0) {
            errorString = [errorString stringByAppendingString:@" and "];
        }
        errorString = [errorString stringByAppendingString:errorArray[i]];
    }
    
    return errorString;
}

- (NSString *)appendErrorString:(NSString *)errorString toMessageString:(NSString *)messageString {
    if (messageString.length > 0) {
        messageString = [messageString stringByAppendingString:@"\n"];
    }
    
    messageString = [messageString stringByAppendingString:errorString];
    
    return messageString;
}

- (NSString *)errorStringFromResponseStatus:(QBResponseStatusCode)statusCode {
    NSString *errorString = nil;
    
    switch (statusCode) {
        case QBResponseStatusCodeServerError:
            errorString = NSLocalizedString(@"QM_STR_BAD_GATEWAY_ERROR", nil);
            break;
        case QBResponseStatusCodeUnknown:
            errorString = NSLocalizedString(@"QM_STR_CONNECTION_NETWORK_ERROR", nil);
            break;
        case QBResponseStatusCodeUnAuthorized:
            errorString = NSLocalizedString(@"QM_STR_INCORRECT_USER_DATA_ERROR", nil);
            break;
        case QBResponseStatusCodeValidationFailed:
            errorString = NSLocalizedString(@"QM_STR_INCORRECT_USER_DATA_ERROR", nil);
            break;
        default:
            errorString = NSLocalizedString(@"QM_STR_UNKNOWN_ERROR", nil);
            break;
    }
    
    return errorString;
}

- (void)handleErrorResponse:(QBResponse *)response {
    
    NSAssert(!response.success, @"Error handling is available only if response success value is False");
    
#warning reachablity here
    //    if (!self.isInternetConnected) {
    //        [REAlertView showAlertWithMessage:NSLocalizedString(@"QM_STR_CHECK_INTERNET_CONNECTION", nil) actionSuccess:NO];
    //        return;
    //    }
    
    NSString *errorMessage = [[NSString alloc] init];
    
    id errorReasons = response.error.reasons[kQMErrorKey];
    
    if (self.isAuthorized) {
        
        if ([errorReasons isKindOfClass:[NSDictionary class]] && errorReasons[kQMBaseKey] != nil) {
            
            errorMessage = [errorReasons[kQMBaseKey] firstObject];
        } else {
            
            errorMessage = [self errorStringFromResponseStatus:response.status];
        }
    }
    else {
        
        if ([errorReasons isKindOfClass:[NSDictionary class]]) {
            
            if (errorReasons[kQMBaseKey] != nil) {
                
                errorMessage = [errorReasons[kQMBaseKey] firstObject];
            }
            else {
                
                if (errorReasons[kQMErrorEmailKey]) {
                    
                    NSString *errorString = [NSString stringWithFormat:NSLocalizedString(@"QM_STR_EMAIL_ERROR", nil), [self errorStringFromArray:errorReasons[kQMErrorEmailKey]]];
                    errorMessage = [self appendErrorString:errorString toMessageString:errorMessage];
                    
                }
                if (errorReasons[kQMErrorFullNameKey]) {
                    
                    NSString *errorString = [NSString stringWithFormat:NSLocalizedString(@"QM_STR_FULL_NAME_ERROR", nil), [self errorStringFromArray:errorReasons[kQMErrorFullNameKey]]];
                    errorMessage = [self appendErrorString:errorString toMessageString:errorMessage];
                    
                }
                if (errorReasons[kQMErrorPasswordKey]) {
                    
                    NSString *errorString = [NSString stringWithFormat:NSLocalizedString(@"QM_STR_PASSWORD_ERROR", nil), [self errorStringFromArray:errorReasons[kQMErrorPasswordKey]]];
                    errorMessage = [self appendErrorString:errorString toMessageString:errorMessage];
                    
                }
            }
        }
        else {
            errorMessage = [self errorStringFromResponseStatus:response.status];
        }
        
    }
    
    [QMNotification showNotificationWithType:QMNotificationPanelTypeFailed message:errorMessage timeUntilDismiss:kQMDefaultNotificationDismissTime];
}

#pragma mark - Auth methods

- (BFTask *)logout {
    
    BFTaskCompletionSource* source = [BFTaskCompletionSource taskCompletionSource];
    
    @weakify(self);
    [super logoutWithCompletion:^{
        @strongify(self);
        
        if (self.currentProfile.accountType == QMAccountTypeFacebook) {
            
            [QMFacebook logout];
        } else if (self.currentProfile.accountType == QMAccountTypeDigits) {
            
            [[Digits sharedInstance] logOut];
        }
        
        [self.currentProfile clearProfile];
        
        [source setResult:nil];
    }];
    
    return source.task;
}

#pragma mark - Chat Connection

- (BFTask *)disconnectFromChat {
    @weakify(self);
    return [[self.chatService disconnect] continueWithBlock:^id _Nullable(BFTask * _Nonnull task) {
        @strongify(self);
        if (!task.isFaulted) {
            
            self.lastActivityDate = [NSDate date];
        }
        
        return nil;
    }];
}

- (BFTask *)disconnectFromChatIfNeeded {
#warning TODO: implement disconnect if needed during active call
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateBackground /*&& !self.avCallManager.hasActiveCall*/ && [[QBChat instance] isConnected]) {
        return [self disconnectFromChat];
    }
    
    return nil;
}

#pragma mark - Notifications

- (BFTask *)leaveChatDialog:(QBChatDialog *)chatDialog {
    
    @weakify(self);
    return [[self.chatService sendNotificationMessageAboutLeavingDialog:chatDialog withNotificationText:kDialogsUpdateNotificationMessage] continueWithBlock:^id _Nullable(BFTask * _Nonnull task) {
        
        if (!task.isFaulted) {
            @strongify(self);
            return [self.chatService deleteDialogWithID:chatDialog.ID];
        }
        
        return nil;
    }];
}

#pragma mark - Last activity date

- (void)setLastActivityDate:(NSDate *)lastActivityDate
{
    [self.defaults setObject:lastActivityDate forKey:kQMLastActivityDateKey];
    [self.defaults synchronize];
}

- (NSDate *)lastActivityDate
{
    return [self.defaults objectForKey:kQMLastActivityDateKey];
}

#pragma mark QMContactListServiceCacheDelegate delegate

- (void)cachedContactListItems:(QMCacheCollection)block {
    
    [[QMContactListCache instance] contactListItems:block];
}

#pragma mark - QMContactListServiceDelegate

- (void)contactListService:(QMContactListService *)__unused contactListService contactListDidChange:(QBContactList *)contactList {
    
    [[QMContactListCache instance] insertOrUpdateContactListItemsWithContactList:contactList completion:nil];
    
    // load users if needed
    [[QMCore instance].usersService getUsersWithIDs:self.contactListService.contactListMemoryStorage.userIDsFromContactList];
}

@end
