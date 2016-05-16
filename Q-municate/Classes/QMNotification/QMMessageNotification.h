//
//  QMMessageNotification.h
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 5/16/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPGNotification.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  QMMessageNotification class interface.
 *  Used as MPGNotification manager for message displaying.
 */
@interface QMMessageNotification : NSObject

/**
 *  Show notification.
 *
 *  @param title         notification title
 *  @param subTitle      notification subtitle
 *  @param iconImage     notification icon image
 *  @param buttonHandler button handler
 */
- (void)showNotificationWithTitle:(NSString *)title
                         subTitle:(nullable NSString *)subTitle
                        iconImage:(UIImage *)iconImage
                    buttonHandler:(MPGNotificationButtonHandler)buttonHandler;

@end

NS_ASSUME_NONNULL_END
