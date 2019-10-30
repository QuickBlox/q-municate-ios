//
//  QMCallNotificationItem.h
//  Q-municate
//
//  Created by Injoit on 7/14/16.
//  Copyright © 2016 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Quickblox/Quickblox.h>

@interface QMCallNotificationItem : NSObject

@property (readonly, strong, nonatomic, nullable) NSString *notificationText;
@property (readonly, strong, nonatomic, nullable) UIImage *iconImage;

- (nullable instancetype)initWithCallNotificationMessage:(nonnull QBChatMessage *)message;

@end
