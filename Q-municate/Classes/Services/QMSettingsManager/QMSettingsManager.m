//
//  QMSettingsManager.m
//  Qmunicate
//
//  Created by Andrey on 24.06.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMSettingsManager.h"
#import <Security/Security.h>
#import "NSUserDefaultsHelper.h"

NSString *const kQMSettingsLoginKey = @"loginKey";
NSString *const kQMSettingsPasswordKey = @"passwordKey";
NSString *const kQMSettingsRememberMeKey = @"rememberMeKey";
NSString *const kQMSettingsPushNotificationEnabled = @"pushNotificationEnabledKey";
NSString *const kQMSettingsUserStatusKey = @"userStatusKey";

@implementation QMSettingsManager

@dynamic login;
@dynamic password;
@dynamic userStatus;
@dynamic pushNotificationsEnabled;
@dynamic rememberMe;

#pragma makr - Login

- (NSString *)login {
    
    NSString *login = defObject(kQMSettingsLoginKey);
    return login;
}

- (void)setLogin:(NSString *)login {
    
    defSetObject(kQMSettingsLoginKey, login);
}

#pragma mark - Password

- (NSString *)password {
    
    NSString *password = defObject(kQMSettingsPasswordKey);
    return password;
}

- (void)setPassword:(NSString *)password {
    
    defSetObject(kQMSettingsPasswordKey, password);
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
    
    self.pushNotificationsEnabled = YES;
    self.userStatus = nil;
    self.login = nil;
    self.password = nil;
    self.rememberMe = NO;
}

@end
