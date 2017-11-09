//
//  QBSettings+Qmunicate.m
//  Q-municate
//
//  Created by Vitaliy Gurkovsky on 11/3/17.
//  Copyright © 2017 Quickblox. All rights reserved.
//

#import "QBSettings+Qmunicate.h"


static NSString * const kQMAppGroupIdentifier = @"group.com.quickblox.qmunicate";

#if DEVELOPMENT == 0
// Production Test
static const NSUInteger kQMApplicationID = 13318;
static NSString * const kQMAuthorizationKey = @"WzrAY7vrGmbgFfP";
static NSString * const kQMAuthorizationSecret = @"xS2uerEveGHmEun";
static NSString * const kQMAccountKey = @"6Qyiz3pZfNsex1Enqnp7";

#else
// Development
static const NSUInteger kQMApplicationID = 36125;
static NSString * const kQMAuthorizationKey = @"gOGVNO4L9cBwkPE";
static NSString * const kQMAuthorizationSecret = @"JdqsMHCjHVYkVxV";
static NSString * const kQMAccountKey = @"6Qyiz3pZfNsex1Enqnp7";

#endif

@implementation QBSettings (Qmunicate)


+ (void)configureForQmunicate {
    
    // Quickblox settings
    QBSettings.applicationID = kQMApplicationID;
    QBSettings.authKey = kQMAuthorizationKey;
    QBSettings.authSecret = kQMAuthorizationSecret;
    QBSettings.accountKey = kQMAccountKey;
    QBSettings.applicationGroupIdentifier = kQMAppGroupIdentifier;
    QBSettings.autoReconnectEnabled = YES;
    QBSettings.carbonsEnabled = YES;
}

@end
