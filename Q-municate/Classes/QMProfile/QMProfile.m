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

static NSString *const kQMUserDataKey = @"userData";
static NSString *const kQMAccountType = @"accountType";
static NSString *const kQMUserAgreementAcceptedKey = @"userAgreementAccepted";
static NSString *const kQMPushNotificationsEnabled = @"pushNotificationsEnabled";
static NSString *const kQMLastDialogsFetchingDate = @"lastDialogsFetchingDate";
static NSString *const kQMAppExists = @"QMAppExists";

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
    
    return success;
}

#pragma mark - Keychain

- (void)keychainQuery:(void(^)(SSKeychainQuery *query))keychainQueryBlock {
    
    NSString *bundleIdentifier = NSBundle.mainBundle.bundleIdentifier;
    NSString *service = [NSString stringWithFormat:@"%@.service", bundleIdentifier];
    NSString *account = [NSString stringWithFormat:@"%@.account", bundleIdentifier];
    
    SSKeychainQuery *query = [[SSKeychainQuery alloc] init];
    query.service = service;
    query.account = account;
    
    keychainQueryBlock(query);
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    
    if (self) {
        
        _userData = [aDecoder decodeObjectForKey:kQMUserDataKey];
        _accountType = [aDecoder decodeIntegerForKey:kQMAccountType];
        _userAgreementAccepted = [aDecoder decodeBoolForKey:kQMUserAgreementAcceptedKey];
        _pushNotificationsEnabled = [aDecoder decodeBoolForKey:kQMPushNotificationsEnabled];
        _lastDialogsFetchingDate = [aDecoder decodeObjectForKey:kQMLastDialogsFetchingDate];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    
    [aCoder encodeObject:self.userData forKey:kQMUserDataKey];
    [aCoder encodeInteger:self.accountType forKey:kQMAccountType];
    [aCoder encodeBool:self.userAgreementAccepted forKey:kQMUserAgreementAcceptedKey];
    [aCoder encodeBool:self.pushNotificationsEnabled forKey:kQMPushNotificationsEnabled];
    [aCoder encodeObject:self.lastDialogsFetchingDate forKey:kQMLastDialogsFetchingDate];
}

@end
