//
//  QMNotificationPanel.h
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 3/26/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QMNotificationPanelView.h"

static const NSUInteger kQMNotificationPanelTag = 345;

NS_ASSUME_NONNULL_BEGIN

@class QMNotificationPanel;

/**
 *  QMNotificationPanelDelegate protocol. Used to notify about notification view actions.
 */
@protocol QMNotificationPanelDelegate <NSObject>

/**
 *  Protocol methods down below are optional and can be ignored
 */
@optional

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
 *  Delegate instance that conforms to QMNotificationPanelDelegate protocol.
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
 *  Determines whether notification is active or not.
 */
@property (assign, nonatomic, readonly) BOOL hasActiveNotification;

/**
 *  Show notification panel in view with custom view.
 *
 *  @param view      custom view for notification panel
 *  @param innerView view to display notification panel in
 *  @param animated  determines whether notification should be shown animated or not
 */
- (void)showNotificationWithView:(UIView *)view inView:(UIView *)innerView animated:(BOOL)animated;

/**
 *  Show notification panel with a specific type in view.
 *
 *  @param notificationType type of notification panel
 *  @param innerView        view to display notification panel in
 *  @param message          notification text
 *  @param animated         determines whether notification should be shown animated or not
 *
 *  @see QMNotificationPanelType
 */
- (void)showNotificationWithType:(QMNotificationPanelType)notificationType
                          inView:(UIView *)innerView
                         message:(nullable NSString *)message
                        animated:(BOOL)animated;

/**
 *  Show notification with type below navigation item.
 *
 *  @param notificationType     type of notification panel
 *  @param navigationController navigation controller, to display message below its item
 *  @param message              notification text
 *  @param animated             determines whether notification should be shown animated or not
 *
 *  @see QMNotificationPanelType
 */
- (void)showNotificationWithType:(QMNotificationPanelType)notificationType
                 belowNavigation:(UINavigationController *)navigationController
                         message:(nullable NSString *)message
                        animated:(BOOL)animated;

/**
 *  Show notification with type by inserting in navigation bar.
 *
 *  @param notificationType type of notification panel
 *  @param navigationBar    navigation bar to insert notification in
 *  @param message          notification text
 *  @param animated         determines whether notification should be shown animated or not
 */
- (void)showNotificationWithType:(QMNotificationPanelType)notificationType
      byInsertingInNavigationBar:(UINavigationBar *)navigationBar
                         message:(NSString *)message
                        animated:(BOOL)animated;

/**
 *  Dismiss notification if existent.
 *
 *  @param animated determines whether dismiss should be animated or no
 */
- (void)dismissNotificationAnimated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
