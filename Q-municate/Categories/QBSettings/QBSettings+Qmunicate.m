//
//  QBSettings+Qmunicate.m
//  Q-municate
//
//  Created by Vitaliy Gurkovsky on 11/3/17.
//  Copyright © 2017 Quickblox. All rights reserved.
//

#import "QBSettings+Qmunicate.h"

@implementation QBSettings (Qmunicate)

+ (void)configure {
    
    switch (QMCurrentApplicationZone) {
            
        case QMApplicationZoneDevelopment:
            
            self.applicationID = 36125;
            self.authKey = @"gOGVNO4L9cBwkPE";
            self.authSecret = @"JdqsMHCjHVYkVxV";
            self.accountKey = @"6Qyiz3pZfNsex1Enqnp7";
            
            break;
            
        case QMApplicationZoneDevelopment1:
            
            self.applicationID  = 63068;
            self.authKey = @"BkWsMWL3XUqJdNr";
            self.authSecret = @"bG8PFjwAx3JKFfS";
            self.accountKey =  @"6Qyiz3pZfNsex1Enqnp7";
            
            break;
            
        case QMApplicationZoneProduction:
            
            self.applicationID = 13318;
            self.authKey = @"WzrAY7vrGmbgFfP";
            self.authSecret = @"xS2uerEveGHmEun";
            self.accountKey = @"6Qyiz3pZfNsex1Enqnp7";
            
            break;
            
        case QMApplicationZoneQA:
            
            self.applicationID = 47;
            self.authKey = @"7JE5cmpMwLd2S22";
            self.authSecret = @"cB4kZeJE7Cbhvg-";
            self.accountKey = @"QmXcTtxj8tTc9y3dJxRo";
            self.apiEndpoint = @"https://apistage1.quickblox.com";
            self.chatEndpoint = @"chatstage1.quickblox.com";
            
            break;
            
        default:
            break;
    }
    
    self.applicationGroupIdentifier = @"group.com.quickblox.qmunicate";
    self.autoReconnectEnabled = YES;
    self.carbonsEnabled = YES;
    
    self.logLevel =
    QMCurrentApplicationZone == QMApplicationZoneProduction ? QBLogLevelNothing : QBLogLevelDebug;
}

@end
