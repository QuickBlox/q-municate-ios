//
//  QMPushNotificationManager.h
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 5/10/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMBaseService.h"


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
 *  Notifying about chat dialog fetching been completed.
 *
 *  @param pushNotificationManager QMPushNotificationManager instance
 *  @param chatDialog              successfully fetched chat dialog
 */
- (void)pushNotificationManager:(QMPushNotificationManager *)pushNotificationManager didSucceedFetchingDialog:(QBChatDialog *)chatDialog;

/**
 *  Protocol methods down below are optional and can be ignored
 */
@optional

/**
 *  Notifying about push notification manager did start loading dialog from server.
 *
 *  @param pushNotificationManager QMPushNotificationManager instance
 */
- (void)pushNotificationManagerDidStartLoadingDialogFromServer:(QMPushNotificationManager *)pushNotificationManager;

/**
 *  Notifying about push notification manager did finish loading dialog from server.
 *
 *  @param pushNotificationManager QMPushNotificationManager instance
 */
- (void)pushNotificationManagerDidFinishLoadingDialogFromServer:(QMPushNotificationManager *)pushNotificationManager;

/**
 *  Notifying about unsuccessful chat dialog fetching.
 *
 *  @param pushNotificationManager QMPushNotificationManager instance
 *  @param error                   error instance
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
@property (copy, nonatomic, nullable) NSData *deviceToken;

/**
 *  Push notification User info dictionary.
 */
@property (copy, nonatomic, nullable) NSDictionary *pushNotification;

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

- (void)registerForPushNotifications;

- (void)handleActionWithIdentifier:(NSString *)identifier
                remoteNotification:(NSDictionary *)userInfo
                      responseInfo:(NSDictionary *)responseInfo
                 completionHandler:(void(^)())completionHandler;
@end

NS_ASSUME_NONNULL_END
