//
//  QMSettingsManager.m
//  Qmunicate
//
//  Created by Andrey Ivanov on 24.06.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMSettingsManager.h"
#import <Security/Security.h>
#import "NSUserDefaultsHelper.h"
#import "SSKeychain.h"

NSString *const kQMSettingsLoginKey = @"loginKey";
NSString *const kQMSettingsRememberMeKey = @"rememberMeKey";
NSString *const kQMSettingsPushNotificationEnabled = @"pushNotificationEnabledKey";
NSString *const kQMSettingsUserStatusKey = @"userStatusKey";
NSString *const kQMAuthServiceKey = @"QMAuthServiceKey";
NSString *const kQMLicenceAcceptedKey = @"licence_accepted";
NSString *const kQMAccountTypeKey = @"accountType";

@implementation QMSettingsManager

@dynamic login;
@dynamic password;
@dynamic userStatus;
@dynamic pushNotificationsEnabled;
@dynamic rememberMe;
@dynamic userAgreementAccepted;
@dynamic accountType;

#pragma makr - accountType

- (void)setAccountType:(QMAccountType)accountType {
    defSetInt(kQMAccountTypeKey, accountType);
}

- (QMAccountType)accountType {
    
    NSUInteger accountType = defInt(kQMAccountTypeKey);
    return accountType;
}

#pragma mark - userAgreementAccepted

- (void)setUserAgreementAccepted:(BOOL)userAgreementAccepted {
    
    defSetBool(kQMLicenceAcceptedKey, userAgreementAccepted);
}

- (BOOL)userAgreementAccepted {
    BOOL accepted = defBool(kQMLicenceAcceptedKey);
    return accepted;
}

#pragma makr - Login

- (void)setLogin:(NSString *)login andPassword:(NSString *)password {

    [self setLogin:login];
    [SSKeychain setPassword:password forService:kQMAuthServiceKey account:login];
}

- (NSString *)login {
    
    NSString *login = defObject(kQMSettingsLoginKey);
    return login;
}

- (void)setLogin:(NSString *)login {
    
    defSetObject(kQMSettingsLoginKey, login);
}

#pragma mark - Password

- (NSString *)password {
    
    NSString *password = [SSKeychain passwordForService:kQMAuthServiceKey account:self.login];
    return password;
}

#pragma mark - Push notifications enabled

- (BOOL)pushNotificationsEnabled {
    
    BOOL pushNotificationEnabled = defBool(kQMSettingsPushNotificationEnabled);
    return pushNotificationEnabled;
}

- (void)setPushNotificationsEnabled:(BOOL)pushNotificationsEnabled {
    
    defSetBool(kQMSettingsPushNotificationEnabled, pushNotificationsEnabled);
}

#pragma makr - remember login

- (BOOL)rememberMe {
    
    BOOL rememberMe = defBool(kQMSettingsRememberMeKey);
    return rememberMe;
}

- (void)setRememberMe:(BOOL)rememberMe {
    
    defSetBool(kQMSettingsRememberMeKey, rememberMe);
}

#pragma mark - User Status

- (NSString *)userStatus {
    
    NSString *userStatus = defObject(kQMSettingsUserStatusKey);
    return userStatus;
}

- (void)setUserStatus:(NSString *)userStatus {
    
    defSetObject(kQMSettingsUserStatusKey, userStatus);
}

#pragma mark - Default Settings

- (void)clearSettings {
    
    [self setLogin:nil andPassword:nil];
    self.userAgreementAccepted = NO;
    self.accountType = QMAccountTypeNone;
    self.pushNotificationsEnabled = YES;
    self.userStatus = nil;
    self.login = nil;
    self.rememberMe = NO;
}

@end
