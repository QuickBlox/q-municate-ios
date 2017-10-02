//
//  QMProfile.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 1/8/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMProfile.h"
#import "QMContent.h"
#import "QMTasks.h"
#import <SSKeychain.h>
#import "QMCore.h"

static NSString * const kQMUserDataKey = @"userData";
static NSString * const kQMAccountType = @"accountType";
static NSString * const kQMUserAgreementAcceptedKey = @"userAgreementAccepted";
static NSString * const kQMPushNotificationsEnabled = @"pushNotificationsEnabled";
static NSString * const kQMLastDialogsFetchingDate = @"lastDialogsFetchingDate";
static NSString * const kQMLastUserFetchDate = @"lastUserFetchDate";
static NSString * const kQMAppExists = @"QMAppExists";

@interface QMProfile ()

@property (strong, nonatomic, readwrite) QBUUser *userData;

@end

@implementation QMProfile

+ (instancetype)currentProfile {
    
    return [[self alloc] init];
}

- (instancetype)init {
    
    self = [super init];
    
    if (self) {
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

        [self loadProfile];
        
        BOOL exist = [defaults boolForKey:kQMAppExists];
        
        if (!exist) {
            [self clearProfile];
        }
    }
    
    return self;
}

- (BOOL)synchronize {
    
    if (self.userData) {
        
        __block BOOL success = NO;
        __block NSError *error = nil;
        
        @weakify(self);
        [self keychainQuery:^(SSKeychainQuery *query) {
            @strongify(self);
            NSCParameterAssert(self.userData.password);
            query.passwordObject = self;
            success = [query save:&error];
        }];
        
        if (success) {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setBool:YES forKey:kQMAppExists];
            [defaults synchronize];
            // updating user in users cache
            [QMCore.instance.usersService.usersMemoryStorage addUser:self.userData];
            [[QMUsersCache instance] insertOrUpdateUser:self.userData];
        }
        else {
            QMLog(@"QMProfile error %@", error);
        }
        
        return success;
    }
 
    return NO;
}

- (BOOL)synchronizeWithUserData:(QBUUser *)userData {
    
    if (self.accountType == QMAccountTypeEmail) {
        NSParameterAssert(userData.password);
    }
    
    self.userData = userData;
    BOOL success = [self synchronize];
    
    if (success) {
        
        [self.delegate profile:self didUpdateUserData:userData];
    }
    
    return success;
}

- (void)loadProfile {
    
    __block QMProfile *profile = nil;
    
    [self keychainQuery:^(SSKeychainQuery *query) {
        NSError *error = nil;
        BOOL success = [query fetch:&error];
        
        if (success) {
            profile = (id)query.passwordObject;
        }
    }];
    
    self.accountType = profile.accountType;
    self.pushNotificationsEnabled = profile.pushNotificationsEnabled;
    self.userAgreementAccepted = profile.userAgreementAccepted;
    self.userData = profile.userData;
    self.lastDialogsFetchingDate = profile.lastDialogsFetchingDate;
    self.lastUserFetchDate = profile.lastUserFetchDate;
}

- (BOOL)clearProfile {
    
    __block BOOL success = NO;
    
    [self keychainQuery:^(SSKeychainQuery *query) {
        
        NSError *error = nil;
        success = [query deleteItem:&error];
    }];
    
    self.userData = nil;
    self.accountType = QMAccountTypeNone;
    self.pushNotificationsEnabled = YES;
    self.userAgreementAccepted = NO;
    self.lastDialogsFetchingDate = nil;
    self.lastUserFetchDate = nil;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:NO forKey:kQMAppExists];
    [defaults synchronize];
    
    return success;
}

//MARK: - Keychain

- (void)keychainQuery:(void(^)(SSKeychainQuery *query))keychainQueryBlock {
    
    NSString *bundleIdentifier = [NSBundle mainBundle].bundleIdentifier;
    NSString *service = [NSString stringWithFormat:@"%@.service", bundleIdentifier];
    NSString *account = [NSString stringWithFormat:@"%@.account", bundleIdentifier];
    
    SSKeychainQuery *query = [[SSKeychainQuery alloc] init];
    query.service = service;
    query.account = account;
    
    keychainQueryBlock(query);
}

//MARK: - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    
    if (self) {
        
        _userData = [aDecoder decodeObjectForKey:kQMUserDataKey];
        _accountType = [aDecoder decodeIntegerForKey:kQMAccountType];
        _userAgreementAccepted = [aDecoder decodeBoolForKey:kQMUserAgreementAcceptedKey];
        _pushNotificationsEnabled = [aDecoder decodeBoolForKey:kQMPushNotificationsEnabled];
        _lastDialogsFetchingDate = [aDecoder decodeObjectForKey:kQMLastDialogsFetchingDate];
        _lastUserFetchDate = [aDecoder decodeObjectForKey:kQMLastUserFetchDate];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    
    [aCoder encodeObject:self.userData forKey:kQMUserDataKey];
    [aCoder encodeInteger:self.accountType forKey:kQMAccountType];
    [aCoder encodeBool:self.userAgreementAccepted forKey:kQMUserAgreementAcceptedKey];
    [aCoder encodeBool:self.pushNotificationsEnabled forKey:kQMPushNotificationsEnabled];
    [aCoder encodeObject:self.lastDialogsFetchingDate forKey:kQMLastDialogsFetchingDate];
    [aCoder encodeObject:self.lastUserFetchDate forKey:kQMLastUserFetchDate];
}

//MARK: - Account migration

// old account service keys
static NSString *const kQMAuthServiceKey = @"QMAuthServiceKey";
static NSString *const kQMLastActivityDateKey = @"last_activity_date";
static NSString *const kQMSettingsPushNotificationEnabled = @"pushNotificationEnabledKey";
static NSString *const kQMSettingsLoginKey = @"loginKey";
static NSString *const kQMSettingsRememberMeKey = @"rememberMeKey";
static NSString *const kQMSettingsUserStatusKey = @"userStatusKey";
static NSString *const kQMLicenceAcceptedKey = @"licence_accepted";

//MARK: - description

- (NSString *)description {
    
    NSMutableString *description = [NSMutableString stringWithString:[super description]];
    [description appendFormat:
     @"\rAccount type: %@"
     "\rPush Notifications Enabled: %s"
     "\rLast Dialogs Fetching Date: %@"
     "\rlastUserFetchDate: %@"
     "\rUserData: %@",
     [self stringForAccountType:_accountType],
     _pushNotificationsEnabled ? "YES" : "NO",
     _lastDialogsFetchingDate,
     _lastUserFetchDate,
     _userData];
    
    return [description copy];
}

- (NSString *)stringForAccountType:(QMAccountType)type {
    
    switch (type) {
        case QMAccountTypeNone: return @"None";
        case QMAccountTypeEmail: return @"Email";
        case QMAccountTypePhone: return @"Phone";
        case QMAccountTypeFacebook: return @"Facebook";
        default:
            break;
    }
}

@end
