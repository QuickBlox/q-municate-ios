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

static NSString *const kQMContactListCacheNameKey = @"q-municate-contacts";

@interface QMCore ()

@property (strong, nonatomic) NSUserDefaults *defaults;

@property (strong, nonatomic) dispatch_group_t logoutGroup;

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
        [QMContactListCache setupDBWithStoreNamed:kQMContactListCacheNameKey];
        _contactListService = [[QMContactListService alloc] initWithServiceManager:self cacheDataSource:self];
        [_contactListService addDelegate:self];
        
        // Profile init
        _currentProfile = [QMProfile currentProfile];
        
        // Users cache init
        [self.usersService loadFromCache];
        
        // managers
        _contactManager = [[QMContactManager alloc] initWithServiceManager:self];
        _chatManager = [[QMChatManager alloc] initWithServiceManager:self];
        _pushNotificationManager = [[QMPushNotificationManager alloc] initWithServiceManager:self];
        _callManager = [[QMCallManager alloc] initWithServiceManager:self];
        
        // Reachability init
        [self configureReachability];
        
        // other initializations
        _defaults = [NSUserDefaults standardUserDefaults];
        _logoutGroup = dispatch_group_create();
    }
    
    return self;
}

- (void)configureReachability {
    
    _internetConnection = [Reachability reachabilityForInternetConnection];
    
    // setting reachable block
    [_internetConnection setReachableBlock:^(Reachability __unused *reachability) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [QMNotification showNotificationPanelWithType:QMNotificationPanelTypeLoading message:NSLocalizedString(@"QM_STR_CONNECTING", nil) timeUntilDismiss:0];
        });
    }];
    
    // setting unreachable block
    [_internetConnection setUnreachableBlock:^(Reachability __unused *reachability) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [QMNotification showNotificationPanelWithType:QMNotificationPanelTypeWarning message:NSLocalizedString(@"QM_STR_LOST_INTERNET_CONNECTION", nil) timeUntilDismiss:kQMDefaultNotificationDismissTime];
        });
    }];
    
    [_internetConnection startNotifier];
}

#pragma mark - Error handling

- (NSString *)errorStringFromResponseStatus:(QBResponseStatusCode)statusCode {
    
    switch (statusCode) {
        case QBResponseStatusCodeServerError:
            return NSLocalizedString(@"QM_STR_BAD_GATEWAY_ERROR", nil);
            
        case QBResponseStatusCodeUnknown:
            return NSLocalizedString(@"QM_STR_CONNECTION_NETWORK_ERROR", nil);
            
        case QBResponseStatusCodeUnAuthorized:
            return NSLocalizedString(@"QM_STR_INCORRECT_USER_DATA_ERROR", nil);
            
        default:
            return nil;
    }
}

- (void)loopErrorArray:(NSArray *)errorArray forMutableString:(NSMutableString *)mutableString {
    
    for (NSString *errStr in errorArray) {
        
        if (errStr != nil) {
            
            [mutableString appendString:errStr];
            [mutableString appendString:@", "];
        }
    }
    
    [mutableString deleteCharactersInRange:NSMakeRange(mutableString.length - 2, 2)];
}

- (void)handleErrorResponse:(QBResponse *)response {
    NSAssert(!response.success, @"Error handling is valid only for unsuccessful response.");
    
    NSString *errorMessage = nil;
    
    if (!self.isInternetConnected) {
        
        errorMessage = NSLocalizedString(@"QM_STR_CHECK_INTERNET_CONNECTION", nil);
    }
    else {
        
        errorMessage = [self errorStringFromResponseStatus:response.status];
        
        if (errorMessage == nil) {
            
            id errorReasons = response.error.reasons[kQMErrorKey];
            
            NSMutableString *mutableString = [NSMutableString new];
            if ([errorReasons isKindOfClass:[NSArray class]]) {
                
                [self loopErrorArray:errorReasons forMutableString:mutableString];
            }
            else if ([errorReasons isKindOfClass:[NSDictionary class]]) {
                
                for (NSString *key in [errorReasons allKeys]) {
                    
                    [mutableString appendString:key];
                    [mutableString appendString:@" "];
                    [self loopErrorArray:errorReasons[key] forMutableString:mutableString];
                    [mutableString appendString:@"\n"];
                }
                
                [mutableString deleteCharactersInRange:NSMakeRange(mutableString.length - 2, 2)];
            }
            
            errorMessage = mutableString.copy;
        }
    }
    
    [QMNotification showNotificationPanelWithType:QMNotificationPanelTypeFailed message:errorMessage timeUntilDismiss:kQMDefaultNotificationDismissTime];
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
        
        dispatch_group_enter(self.logoutGroup);
        [[self.pushNotificationManager unSubscribeFromPushNotifications] continueWithBlock:^id _Nullable(BFTask * _Nonnull __unused task) {
            
            dispatch_group_leave(self.logoutGroup);
            return nil;
        }];
        
        dispatch_group_enter(self.logoutGroup);
        [[QMContactListCache instance] deleteContactList:^{
            
            dispatch_group_leave(self.logoutGroup);
        }];
        
        dispatch_group_notify(self.logoutGroup, dispatch_get_main_queue(), ^{
            
            self.lastActivityDate = nil;
            [self.currentProfile clearProfile];
            [source setResult:nil];
        });
    }];
    
    return source.task;
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

#pragma mark - Helpers

- (BOOL)isInternetConnected {
    
    return self.internetConnection.isReachable;
}

@end
