//
//  QMChatUtils.h
//  Q-municate
//
//  Created by Igor Alefirenko on 17.10.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QMChatUtils : NSObject

+ (NSString *)messageTextForNotification:(QBChatMessage *)notification;
+ (NSString *)messageTextForPushWithNotification:(QBChatMessage *)notification;
+ (NSString *)idsStringWithoutSpaces:(NSArray *)users;
+ (NSString *)messageForText:(NSString *)text participants:(NSArray *)participants;

@end
