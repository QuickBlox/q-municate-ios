//
//  QMNotificationPanelView.h
//  Q-municate
//
//  Created by Injoit on 3/26/16.
//  Copyright © 2016 QuickBlox. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Type of notification.
 */
typedef NS_ENUM(NSUInteger, QMNotificationPanelType) {
    /**
     *  Success notification, green background, success image.
     */
    QMNotificationPanelTypeSuccess,
    /**
     *  Warning notification, yellow background, warning image.
     */
    QMNotificationPanelTypeWarning,
    /**
     *  Failed notification, red background, failed image.
     */
    QMNotificationPanelTypeFailed,
    /**
     *  Loading notification, light blue background, activity indicator.
     */
    QMNotificationPanelTypeLoading
};

/**
 *  Notification panel default view. Used in basic notifications as a default view.
 */
@interface QMNotificationPanelView : UIView

/**
 *  Notification panel type.
 */
@property (assign, nonatomic) QMNotificationPanelType notificationPanelType;

/**
 *  Notification panel view message.
 */
@property (copy, nonatomic, nullable) NSString *message;

- (nullable instancetype)init NS_UNAVAILABLE;
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;

/**
 *  Init with frame and notification type.
 *
 *  @param frame                 desired frame
 *  @param notificationPanelType notification type
 *
 *  @see QMNotificationPanelType
 *
 *  @return QMNotificationPanelView new instance.
 */
- (nullable instancetype)initWithFrame:(CGRect)frame
                 notificationPanelType:(QMNotificationPanelType)notificationPanelType;

@end

NS_ASSUME_NONNULL_END
