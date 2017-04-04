//
//  QMMessageNotification.h
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 5/16/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPGNotification.h"

/**
 *  Icon image frame.
 */
extern const CGRect QMMessageNotificationIconRect;

NS_ASSUME_NONNULL_BEGIN

/**
 *  QMMessageNotification class interface.
 *  Used as MPGNotification manager for message displaying.
 */
@interface QMMessageNotification : NSObject

/**
 *  Host view controller of message notification.
 *
 *  @note Becomes nil after the notification is automatically dismissed.
 */
@property (weak, nonatomic, nullable) __kindof UIViewController *hostViewController;

/**
 *  Show notification.
 *
 *  @param title            notification title
 *  @param subTitle         notification subtitle
 *  @param iconImageURL     URL for icon image
 *  @param placeholderImage placeholder for icon image
 *  @param buttonHandler    button handler
 */
- (void)showNotificationWithTitle:(NSString *)title
                         subTitle:(nullable NSString *)subTitle
                     iconImageURL:(nullable NSURL *)iconImageURL
                    buttonHandler:(nullable MPGNotificationButtonHandler)buttonHandler;

@end

NS_ASSUME_NONNULL_END
