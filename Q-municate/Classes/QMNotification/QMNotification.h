//
//  QMNotification.h
//  Q-municate
//
//  Created by Injoit on 4/18/16.
//  Copyright © 2016 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Quickblox/Quickblox.h>
#import <Bolts/Bolts.h>
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
 *  @param hvc   host view controller for notification view
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

/**
 *  Send push notification for user with text, extra params and possibly VOIP.
 *
 *  @param user user to send push notification to
 *  @param text text for push notification
 *  @param extraParams additional parameters to send in payload
 *  @param isVoip determines whether push should be voip if possible
 *
 *  @return BFTask with completion
 */
+ (BFTask *)sendPushNotificationToUser:(QBUUser *)user withText:(NSString *)text extraParams:(nullable NSDictionary *)extraParams isVoip:(BOOL)isVoip;

@end

NS_ASSUME_NONNULL_END
