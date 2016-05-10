//
//  QMPushNotificationManager.h
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 5/10/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

@class QMPushNotificationManager;

NS_ASSUME_NONNULL_BEGIN

/**
 *  QMPushNotificationManagerDelegate protocol. Used to notify about push notification handling.
 */
@protocol QMPushNotificationManagerDelegate <NSObject>

/**
 *  Protocol methods down below are required to be implemented
 */
@required

/**
 *  Is called when dialog fetching is complete and ready to return requested dialog
 *
 *  @param chatDialog QBChatDialog instance. Successfully fetched dialog
 */
- (void)pushNotificationManager:(QMPushNotificationManager *)pushNotificationManager didSucceedFetchingDialog:(QBChatDialog *)chatDialog;

/**
 *  Protocol methods down below are optional and can be ignored
 */
@optional

/**
 *  Is called when dialog was not found nor in memory storage nor in cache
 *  and NotificationHandler started requesting dialog from server
 */
- (void)pushNotificationManagerDidStartLoadingDialogFromServer:(QMPushNotificationManager *)pushNotificationManager;

/**
 *  Is called when dialog request from server was completed
 */
- (void)pushNotificationManagerDidFinishLoadingDialogFromServer:(QMPushNotificationManager *)pushNotificationManager;

/**
 *  Is called when dialog was not found in both memory storage and cache
 *  and server request return nil
 */
- (void)pushNotificationManager:(QMPushNotificationManager *)pushNotificationManager didFailFetchingDialogWithError:(NSError *)error;

@end

/**
 *  QMPushNotificationManager class interface.
 *  Used to manage push notifications.
 */
@interface QMPushNotificationManager : QMBaseService

/**
 *  Current device token. Used for subscribing for push notifications.
 */
@property (strong, nonatomic, nullable) NSData *deviceToken;

/**
 *  Push notification User info dictionary.
 */
@property (strong, nonatomic, nullable) NSDictionary *pushNotification;

/**
 *  Subscribe for push notifications.
 *
 *  @return BFTask with result or nil if cannot subscribe
 */
- (nullable BFTask *)subscribeForPushNotifications;

/**
 *  Unsubscribe from push notifications.
 *
 *  @return BFTask with result
 */
- (BFTask *)unSubscribeFromPushNotifications;

/**
 *  Handle push notification with delegate.
 *
 *  @param delegate delegate instance that conforms to QMPushNotificationManagerDelegate protocol
 */
- (void)handlePushNotificationWithDelegate:(id<QMPushNotificationManagerDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
