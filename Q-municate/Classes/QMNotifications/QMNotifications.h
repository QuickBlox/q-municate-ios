//
//  QMNotifications.h
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 3/4/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QMNotifications : NSObject

+ (QBChatMessage *)contactRequestNotificationForUser:(QBUUser *)user withChatDialog:(QBChatDialog *)chatDialog;

+ (BFTask *)sendPushNotificationToUser:(QBUUser *)user withText:(NSString *)text;

@end
