//
//  QMSettingsManager.h
//  Qmunicate
//
//  Created by Andrey Ivanov on 24.06.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QMSettingsManager : NSObject

/**
 * User login
 */
@property (strong, nonatomic, readonly) NSString *login;

/**
 * User password
 */
@property (strong, nonatomic, readonly) NSString *password;

/**
 * User status
 */
@property (strong, nonatomic) NSString *userStatus;

/**
 * Push notifcation enable (Default YES)
 */
@property (assign, nonatomic) BOOL pushNotificationsEnabled;

/**
 * Remember user login and password
 */
@property (assign, nonatomic) BOOL rememberMe;

- (void)setLogin:(NSString *)login andPassword:(NSString *)password;
/**
 * Set Default settings
 */
- (void)clearSettings;

@end
