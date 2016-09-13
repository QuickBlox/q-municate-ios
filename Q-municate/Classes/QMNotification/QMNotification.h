//
//  QMNotification.h
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 4/18/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPGNotification.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  QMNotification class interface.
 *  Used as overall main notification handling class.
 */
@interface QMNotification : NSObject

/**
 *  Show message notification for message.
 *
 *  @param chatMessage          chat message
 *  @param buttonHandler        button handler blocks
 *  @param hostViewController   host view controller for notification view
 */
+ (void)showMessageNotificationWithMessage:(QBChatMessage *)chatMessage buttonHandler:(MPGNotificationButtonHandler)buttonHandler hostViewController:(UIViewController *)hvc;

/**
 *  Send push notification for user with text.
 *
 *  @param user user to send push notification to
 *  @param text text for push notification
 *
 *  @return BFTask with completion
 */
+ (BFTask *)sendPushNotificationToUser:(QBUUser *)user withText:(NSString *)text;

@end

NS_ASSUME_NONNULL_END
