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
#import "QMApi.h"

NSString *const kQMSettingsLoginKey = @"loginKey";
NSString *const kQMSettingsRememberMeKey = @"rememberMeKey";
NSString *const kQMFirstFacebookLoginKey = @"first_facebook_login";
NSString *const kQMSettingsPushNotificationEnabled = @"pushNotificationEnabledKey";
NSString *const kQMSettingsUserStatusKey = @"userStatusKey";
NSString *const kQMAuthServiceKey = @"QMAuthServiceKey";
NSString *const kQMLicenceAcceptedKey = @"licence_accepted";
NSString *const kQMAccountTypeKey = @"accountType";
NSString *const kQMApplicationEnteredFromPushKey = @"app_entered_from_push";
NSString *const kQMLastActivityDateKey = @"last_activity_date";
NSString *const kQMDialogWithIDisActiveKey = @"dialog_is_active";


@implementation QMSettingsManager

@dynamic login;
@dynamic password;
@dynamic userStatus;
@dynamic pushNotificationsEnabled;
@dynamic rememberMe;
@dynamic userAgreementAccepted;
@dynamic accountType;

#pragma mark - accountType

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

#pragma mark - Login

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

#pragma mark - remember login

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

#pragma mark - Last activity date

- (void)setLastActivityDate:(NSDate *)lastActivityDate
{
    defSetObject(kQMLastActivityDateKey, lastActivityDate);
}

- (NSDate *)lastActivityDate
{
    return defObject(kQMLastActivityDateKey);
}


#pragma mark - Default Settings

- (void)defaultSettings {
    self.pushNotificationsEnabled = YES;
}

- (void)clearSettings {
    [self defaultSettings];
    self.rememberMe = NO;
    [self setLogin:nil andPassword:nil];
    self.userAgreementAccepted = NO;
    self.accountType = QMAccountTypeNone;
    self.userStatus = nil;
    self.login = nil;
    self.lastActivityDate = nil;
}

@end
