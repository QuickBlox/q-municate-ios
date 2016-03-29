//
//  QMNotificationPanel.h
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 3/26/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QMNotificationPanelView.h"

NS_ASSUME_NONNULL_BEGIN

@class QMNotificationPanel;

/**
 *  QMNotificationPanelDelegate protocol. Used to notify about notification view actions.
 */
@protocol QMNotificationPanelDelegate <NSObject>

/**
 *  Protocol methods down below are required to be implemented
 */
@required

/**
 *  Notifying about notification panel did dismiss.
 *
 *  @param notificationPanel QMNotificationPanel instance.
 */
- (void)notificationPanelDidDismiss:(QMNotificationPanel *)notificationPanel;

/**
 *  Notifying about notification panel did receive tap.
 *
 *  @param notificationPanel QMNotificationPanel instance.
 *  @param recognizer        UITapGestureRecognizer instance.
 */
- (void)notificationPanel:(QMNotificationPanel *)notificationPanel didRecognizedTap:(UITapGestureRecognizer *)recognizer;

@end

/**
 *  Notification panel. Use it to show any notification in any place of the app.
 */
@interface QMNotificationPanel : NSObject

/**
 *  Delegate instance that conforms to QMNotificationPanelDelegate protocol
 */
@property (weak, nonatomic, nullable) id <QMNotificationPanelDelegate>delegate;

/**
 *  Determines whether dismiss on panel tap is enabled.
 *  Default value: YES
 */
@property (assign, nonatomic, getter=isTapDismissEnabled) BOOL enableTapDismiss;

/**
 *  Time interval until panel will be dismissed. Set to 0 to make it permanent.
 *  Default value: 2.0f
 */
@property (assign, nonatomic) NSTimeInterval timeUntilDismiss;

/**
 *  Show notification panel in view with custom view.
 *
 *  @param view      custom view for notification panel
 *  @param innerView view to display notification panel in
 */
- (void)showNotificationWithView:(UIView *)view inView:(UIView *)innerView;

/**
 *  Show notification panel with a specific type in view/
 *
 *  @param notificationType type of notification panel
 *  @param innerView        view to display notification panel in
 *  @param message          notification text
 *
 *  @see QMNotificationPanelType
 */
- (void)showNotificationWithType:(QMNotificationPanelType)notificationType
                          inView:(UIView *)innerView
                         message:(nullable NSString *)message;

/**
 *  Show notification with type below navigation item
 *
 *  @param notificationType     type of notification panel
 *  @param navigationController navigation controller, to display message below its item
 *  @param message              notification text
 *
 *  @see QMNotificationPanelType
 */
- (void)showNotificationWithType:(QMNotificationPanelType)notificationType
                 belowNavigation:(UINavigationController *)navigationController
                         message:(nullable NSString *)message;

/**
 *  Dismiss notification if existent.
 */
- (void)dismissNotification;

@end

NS_ASSUME_NONNULL_END
