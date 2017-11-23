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
#if CUSTOMSERVER == 1
    [self configureForTestServer];
#else
    QBSettings.applicationID = kQMApplicationID;
    QBSettings.authKey = kQMAuthorizationKey;
    QBSettings.authSecret = kQMAuthorizationSecret;
    QBSettings.accountKey = kQMAccountKey;
    QBSettings.applicationGroupIdentifier = kQMAppGroupIdentifier;
    QBSettings.autoReconnectEnabled = YES;
    QBSettings.carbonsEnabled = YES;
#endif
}

+ (void)configureForTestServer {
    // Quickblox settings
    QBSettings.applicationID = 47;
    QBSettings.authKey = @"7JE5cmpMwLd2S22";
    QBSettings.authSecret = @"cB4kZeJE7Cbhvg-";
    QBSettings.accountKey = @"QmXcTtxj8tTc9y3dJxRo";
    QBSettings.applicationGroupIdentifier = kQMAppGroupIdentifier;
    QBSettings.autoReconnectEnabled = YES;
    QBSettings.carbonsEnabled = YES;
    QBSettings.apiEndpoint = @"https://apistage1.quickblox.com";
    QBSettings.chatEndpoint = @"chatstage1.quickblox.com";
}

@end
