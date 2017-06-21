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
        
        if (_userData != nil && !exist) {
            
            [self clearProfile];
        }
        else if (_userData == nil && [QBSession currentSession].currentUser != nil) {
            
            // support for updating from old qmunicate (version less than 2.0)
            // initializing QMProfile from previous data savings
            [self _performAccountMigration];
        }
    }
    
    return self;
}

- (BOOL)synchronize {
    NSParameterAssert(self.userData);
    
    __block BOOL success = NO;
    
    @weakify(self);
    [self keychainQuery:^(SSKeychainQuery *query) {
        @strongify(self);
        query.passwordObject = self;
        NSError *error = nil;
        success = [query save:&error];
    }];
    
    if (success) {
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setBool:YES forKey:kQMAppExists];
        
        // updating user in users cache
        [[QMCore instance].usersService.usersMemoryStorage addUser:self.userData];
        [[QMUsersCache instance] insertOrUpdateUser:self.userData];
    }
    
    return success;
}

- (BOOL)synchronizeWithUserData:(QBUUser *)userData {
    
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
    self.pushNotificationsEnabled = NO;
    self.userAgreementAccepted = NO;
    self.lastDialogsFetchingDate = nil;
    self.lastUserFetchDate = nil;
    
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

- (void)_performAccountMigration {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    self.accountType = [userDefaults integerForKey:kQMAccountType];
    
    if (self.accountType != QMAccountTypeNone) {
        
        // last dialogs fetching date
        self.lastDialogsFetchingDate = [userDefaults objectForKey:kQMLastActivityDateKey];
        // push notifications enabled
        self.pushNotificationsEnabled = [userDefaults boolForKey:kQMSettingsPushNotificationEnabled];
        
        // clearing all old account information
        [userDefaults removeObjectForKey:kQMAccountType];
        [userDefaults removeObjectForKey:kQMLastActivityDateKey];
        [userDefaults removeObjectForKey:kQMSettingsPushNotificationEnabled];
        [userDefaults removeObjectForKey:kQMSettingsLoginKey];
        [userDefaults removeObjectForKey:kQMSettingsRememberMeKey];
        [userDefaults removeObjectForKey:kQMSettingsUserStatusKey];
        [userDefaults removeObjectForKey:kQMLicenceAcceptedKey];
        
        [userDefaults synchronize];
        
        if (self.accountType == QMAccountTypeEmail) {
            
            NSString *account = [QBSession currentSession].currentUser.email;
            [QBSession currentSession].currentUser.password = [SSKeychain passwordForService:kQMAuthServiceKey account:account];
            
            // clearing old account data
            [SSKeychain deletePasswordForService:kQMAuthServiceKey account:account];
        }
        
        _userData = [QBSession currentSession].currentUser;
        [self synchronize];
    }
}

@end
