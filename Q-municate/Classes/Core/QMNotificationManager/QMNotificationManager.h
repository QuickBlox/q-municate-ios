//
//  QMNotificationManager.h
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 3/26/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMBaseService.h"
#import "QMNotificationPanel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  This class represents basic notification managing and tasks.
 */
@interface QMNotificationManager : QMBaseService

/**
 *  Contact request notification message instance.
 *
 *  @param user       user to create notification message for
 *
 *  @return QBChatMessage notification instance
 */
- (QBChatMessage *)contactRequestNotificationForUser:(QBUUser *)user;

/**
 *  Remove contact notification message instance.
 *
 *  @param user       user to create notification message for
 *
 *  @return QBChatMessage notification instance
 */
- (QBChatMessage *)removeContactNotificationForUser:(QBUUser *)user;

/**
 *  Show notification with type and message.
 *
 *  @param notificationType notification type
 *  @param message          message to display in notification
 *  @param timeUntilDismiss time until notification will be dismissed
 *
 *  @see QMNotificationPanelType
 */
- (void)showNotificationWithType:(QMNotificationPanelType)notificationType message:(nullable NSString *)message timeUntilDismiss:(NSTimeInterval)timeUntilDismiss;

/**
 *  Dismiss current notification.
 */
- (void)dismissNotification;

/**
 *  Send push notification for user with text.
 *
 *  @param user user to send push notification to
 *  @param text text for push notification
 *
 *  @return BFTask with completion
 */
- (BFTask *)sendPushNotificationToUser:(QBUUser *)user withText:(NSString *)text;

@end

NS_ASSUME_NONNULL_END
