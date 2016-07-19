//
//  QMCallNotificationItem.h
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 7/14/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QMCallNotificationItem : NSObject

@property (readonly, strong, nonatomic, nullable) NSString *notificationText;
@property (readonly, strong, nonatomic, nullable) UIImage *iconImage;

- (nullable instancetype)initWithCallNotificationMessage:(nonnull QBChatMessage *)message;

@end
