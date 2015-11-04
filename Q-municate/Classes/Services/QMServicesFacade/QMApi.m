//
//  QMApi.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 9/24/15.
//  Copyright © 2015 Quickblox. All rights reserved.
//

#import "QMApi.h"

#import "QMSettingsManager.h"
#import "QMAVCallManager.h"
#import "QMContentService.h"
#import <Reachability.h>
#import <SVProgressHUD.h>
#import "REAlertView+QMSuccess.h"

const NSTimeInterval kQMPresenceTime = 30;

static NSString *const kQMErrorKey         = @"errors";
static NSString *const kQMErrorEmailKey    = @"email";
static NSString *const kQMErrorFullNameKey = @"full_name";
static NSString *const kQMErrorPasswordKey = @"password";

@interface QMApi()

@property (strong, nonatomic) QMSettingsManager *settingsManager;
@property (strong, nonatomic) QMContactListService* contactListService;
@property (strong, nonatomic) QMAVCallManager *avCallManager;
@property (strong, nonatomic) QMContentService *contentService;
@property (strong, nonatomic) QMUsersService* usersService;
@property (strong, nonatomic) Reachability *internetConnection;
@property (strong, nonatomic) NSTimer *presenceTimer;

@end

@implementation QMApi

+ (instancetype)instance {
    
    static QMApi *servicesFacade = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        servicesFacade = [[self alloc] init];
        [QBChat instance].autoReconnectEnabled = YES;

        servicesFacade.presenceTimer = [NSTimer scheduledTimerWithTimeInterval:kQMPresenceTime
                                                                        target:servicesFacade
                                                                      selector:@selector(sendPresence)
                                                                      userInfo:nil
                                                                       repeats:YES];
    });
    
    return servicesFacade;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        
#if QM_AUDIO_VIDEO_ENABLED == 1
        _avCallManager = [[QMAVCallManager alloc] initWithServiceManager:self];
#endif
        
//        [QMChatCache setupDBWithStoreNamed:kChatCacheNameKey];
//        [QMChatCache instance].messagesLimitPerDialog = 10;
        [QMContactListCache setupDBWithStoreNamed:kContactListCacheNameKey];
        _contactListService = [[QMContactListService alloc] initWithServiceManager:self cacheDataSource:self];
        _settingsManager = [[QMSettingsManager alloc] init];
        _contentService = [[QMContentService alloc] init];
        _internetConnection = [Reachability reachabilityForInternetConnection];
        
        [self.chatService addDelegate:self];
        
        __weak __typeof(self)weakSelf = self;
        void (^internetConnectionReachable)(Reachability *reachability) = ^(Reachability *reachability) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (weakSelf.isAuthorized) {
                    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
                    [weakSelf applicationDidBecomeActive:nil];
                }
            });
        };
        void (^internetConnectionNotReachable)(Reachability *reachability) = ^(Reachability *reachability) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"QM_STR_LOST_INTERNET_CONNECTION", nil) maskType:SVProgressHUDMaskTypeNone];
            });
        };
        
        self.internetConnection.reachableBlock = internetConnectionReachable;
        self.internetConnection.unreachableBlock = internetConnectionNotReachable;
    }
    
    [self.internetConnection startNotifier];
    return self;
}

- (BOOL)isInternetConnected {
    
    return self.internetConnection.isReachable;
}

#pragma mark - STATUS

- (void)sendPresence {
    
    if ([[QBChat instance] isConnected]) {
        [[QBChat instance] sendPresence];
    }
}

- (void)applicationDidBecomeActive:(void(^)(BOOL success))completion {
    
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_enter(group);
    
    __weak __typeof(self)weakSelf = self;
    [self.chatService fetchDialogsUpdatedFromDate:self.settingsManager.lastActivityDate andPageLimit:kQMDialogsPageLimit iterationBlock:nil completionBlock:^(QBResponse *response) {
        //
        weakSelf.settingsManager.lastActivityDate = [NSDate date];
        dispatch_group_leave(group);
    }];
    
    dispatch_group_enter(group);
    [self connectChat:^(BOOL success) {
        dispatch_group_leave(group);
    }];
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        
        if ([QBChat instance].isLoggedIn) {
            [self joinGroupDialogs];
            if (completion) completion(YES);
        }
        else {
            if (completion) completion(NO);
        }
    });
}

- (void)applicationWillResignActive {
    [self disconnectFromChat];
}

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
    NSString *errorString = [[NSString alloc] init];
    
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

#pragma mark QMContactListServiceCacheDelegate delegate

- (void)cachedUsers:(QMCacheCollection)block {
    [[QMUsersCache.instance usersSortedBy:@"id" ascending:YES] continueWithExecutor:[BFExecutor mainThreadExecutor]
                                                                          withBlock:^id(BFTask<NSArray<QBUUser *> *> *task) {
                                                                              if (block) block(task.result);
                                                                              return nil;
                                                                          }];
}

- (void)cachedContactListItems:(QMCacheCollection)block {
    [QMContactListCache.instance contactListItems:block];
}

#pragma mark QMServicesManagerProtocol

- (BOOL)isAuthorized {
    return self.authService.isAuthorized;
}

- (void)handleErrorResponse:(QBResponse *)response {
    
    NSAssert(!response.success, @"Error handling is available only if response success value is False");
    
    if (!self.isInternetConnected) {
        [REAlertView showAlertWithMessage:NSLocalizedString(@"QM_STR_CHECK_INTERNET_CONNECTION", nil) actionSuccess:NO];
        return;
    }
    
    NSString *errorMessage = [[NSString alloc] init];
    
    if (self.isAuthorized) {
        errorMessage = [self errorStringFromResponseStatus:response.status];
    }
    else {
        
        id errorReasons = response.error.reasons[kQMErrorKey];
        
        if ([errorReasons isKindOfClass:[NSDictionary class]]) {
            //
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
        else {
            errorMessage = [self errorStringFromResponseStatus:response.status];
        }
        
    }
    
    [REAlertView showAlertWithMessage:errorMessage actionSuccess:NO];
}

#pragma mark QMChatServiceDelegate

- (void)chatService:(QMChatService *)chatService didLoadChatDialogsFromCache:(NSArray *)dialogs withUsers:(NSSet *)dialogsUsersIDs {
    [self.usersService getUsersWithIDs:[dialogsUsersIDs allObjects]];
}

@end

@implementation NSObject(CurrentUser)

@dynamic currentUser;

- (QBUUser *)currentUser {
    return [QBSession currentSession].currentUser;
}

@end