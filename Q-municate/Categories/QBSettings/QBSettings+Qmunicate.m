//
//  QBSettings+Qmunicate.m
//  Q-municate
//
//  Created by Injoit on 11/3/17.
//  Copyright © 2017 QuickBlox. All rights reserved.
//

#import "QBSettings+Qmunicate.h"

@implementation QBSettings (Qmunicate)

+ (void)configure {
    
    switch (QMCurrentApplicationZone) {
            
            case QMApplicationZoneDevelopment: {
                self.applicationID = 0;
                self.authKey = @"";
                self.authSecret = @"";
                self.accountKey = @"";
                self.apiEndpoint = @"";
                self.chatEndpoint = @"";
                
                break;
            }
            
            case QMApplicationZoneProduction: {
                
                self.applicationID = 0;
                self.authKey = @"";
                self.authSecret = @"";
                self.accountKey = @"";
                self.apiEndpoint = @"";
                self.chatEndpoint = @"";
                
                break;
            }
            
            case QMApplicationZoneQA: {
                self.applicationID = 0;
                self.authKey = @"";
                self.authSecret = @"";
                self.accountKey = @"";
                self.apiEndpoint = @"";
                self.chatEndpoint = @"";
                
                break;
            }
            
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
