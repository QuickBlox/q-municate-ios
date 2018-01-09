//
//  QBSettings+Qmunicate.m
//  Q-municate
//
//  Created by Vitaliy Gurkovsky on 11/3/17.
//  Copyright © 2017 Quickblox. All rights reserved.
//

#import "QBSettings+Qmunicate.h"

@implementation QBSettings (Qmunicate)

+ (void)configure{
    
    switch (QMCurrentApplicationZone) {
            
        case QMApplicationZoneDevelopment:
            
            QBSettings.applicationID = 36125;
            QBSettings.authKey = @"gOGVNO4L9cBwkPE";
            QBSettings.authSecret = @"JdqsMHCjHVYkVxV";
            QBSettings.accountKey = @"6Qyiz3pZfNsex1Enqnp7";
            
            break;
            
        case QMApplicationZoneDevelopment1:
            
            QBSettings.applicationID  = 63068;
            QBSettings.authKey = @"BkWsMWL3XUqJdNr";
            QBSettings.authSecret = @"bG8PFjwAx3JKFfS";
            QBSettings.accountKey =  @"6Qyiz3pZfNsex1Enqnp7";
            
            break;
            
        case QMApplicationZoneProduction:
            
            QBSettings.applicationID = 13318;
            QBSettings.authKey = @"WzrAY7vrGmbgFfP";
            QBSettings.authSecret = @"xS2uerEveGHmEun";
            QBSettings.accountKey = @"6Qyiz3pZfNsex1Enqnp7";
            
            break;
            
        case QMApplicationZoneQA:
            
            QBSettings.applicationID = 47;
            QBSettings.authKey = @"7JE5cmpMwLd2S22";
            QBSettings.authSecret = @"cB4kZeJE7Cbhvg-";
            QBSettings.accountKey = @"QmXcTtxj8tTc9y3dJxRo";
            QBSettings.apiEndpoint = @"https://apistage1.quickblox.com";
            QBSettings.chatEndpoint = @"chatstage1.quickblox.com";
            
            break;
            
        default:
            break;
    }
    
    QBSettings.applicationGroupIdentifier = @"group.com.quickblox.qmunicate";
    QBSettings.autoReconnectEnabled = YES;
    QBSettings.carbonsEnabled = YES;
    
    QBSettings.logLevel =
    QMCurrentApplicationZone == QMApplicationZoneProduction ? QBLogLevelNothing : QBLogLevelDebug;
    
    [QBSettings settingsFromPlist];
}

@end
