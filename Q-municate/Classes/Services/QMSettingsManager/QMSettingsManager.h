//
//  QMSettingsManager.h
//  Qmunicate
//
//  Created by Andrey on 24.06.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QMSettingsManager : NSObject

/**
 * User login
 */
@property (strong, nonatomic) NSString *login;

/**
 * User password
 */
@property (strong, nonatomic) NSString *password;

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

/**
 * Set Default settings
 */
- (void)clearSettings;

@end
