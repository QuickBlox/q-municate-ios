//
//  QMApi+Notifications.m
//  Q-municate
//
//  Created by Igor Alefirenko on 02.10.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMApi.h"
#import "QMMessagesService.h"
#import "QMChatDialogsService.h"
#import "QMChatUtils.h"


@implementation QMApi (Notifications)


- (void)sendContactRequestSendNotificationToUser:(QBUUser *)user completion:(void(^)(NSError *error, QBChatMessage *notification))completionBlock
{
    QBChatMessage *notification = [self notificationForUser:user];
    notification.cParamNotificationType = QMMessageNotificationTypeSendContactRequest;
    [self sendNotification:notification completion:completionBlock];
}

- (void)sendContactRequestConfirmNotificationToUser:(QBUUser *)user completion:(void(^)(NSError *error, QBChatMessage *notification))completionBlock
{
    QBChatMessage *notification = [self notificationForUser:user];
    notification.cParamNotificationType = QMMessageNotificationTypeConfirmContactRequest;
    [self sendNotification:notification completion:completionBlock];
}

- (void)sendContactRequestRejectNotificationToUser:(QBUUser *)user completion:(void(^)(NSError *error, QBChatMessage *notification))completionBlock
{
    QBChatMessage *notification = [self notificationForUser:user];
    notification.cParamNotificationType = QMMessageNotificationTypeRejectContactRequest;
    [self sendNotification:notification completion:completionBlock];
}

- (void)sendContactRequestDeleteNotificationToUser:(QBUUser *)user completion:(void(^)(NSError *error, QBChatMessage *notification))completionBlock
{
    QBChatMessage *notification = [self notificationForUser:user];
    notification.cParamNotificationType = QMMessageNotificationTypeDeleteContactRequest;
    [self sendNotification:notification completion:completionBlock];
}

- (QBChatMessage *)notificationForUser:(QBUUser *)user
{
    QBChatMessage *notification = [QBChatMessage message];
    notification.recipientID = user.ID;
    notification.senderID = self.messagesService.currentUser.ID;
    return notification;
}

- (void)sendNotification:(QBChatMessage *)notification completion:(void(^)(NSError *error, QBChatMessage *notification))completionBlock
{
    QBChatDialog *dialog = [self.chatDialogsService privateDialogWithOpponentID:notification.recipientID];
    NSAssert(dialog, @"Dialog not found. Please ");
    if (notification.cParamNotificationType == QMMessageNotificationTypeSendContactRequest) {
        notification.cParamDialogOccupantsIDs = dialog.occupantIDs;
    }
    notification.text = [QMChatUtils messageTextForNotification:notification];
    
    __weak typeof(self) weakSelf = self;
    [self.messagesService sendMessage:notification withDialogID:dialog.ID saveToHistory:YES completion:^(NSError *error) {
        if (!error) {
            [weakSelf.messagesService addMessageToHistory:notification withDialogID:dialog.ID];
            [dialog updateLastMessageInfoWithMessage:notification];
            completionBlock(nil, notification);
        } else {
            completionBlock(error, nil);
        }
    }];
    [self sendPushContactRequestNotification:notification];
}


#pragma mark - Push Notifications

- (void)sendPushContactRequestNotification:(QBChatMessage *)notification
{
    NSString *message = [QMChatUtils messageTextForPushWithNotification:notification];
    QBMEvent *event = [QBMEvent event];
    event.notificationType = QBMNotificationTypePush;
    event.usersIDs = [NSString stringWithFormat:@"%d", notification.recipientID];
    event.isDevelopmentEnvironment = ![QBSettings isUseProductionEnvironmentForPushNotifications];
    event.type = QBMEventTypeOneShot;
    //
    // custom params
    NSDictionary  *dictPush = @{@"message" : message,
                                       @"ios_badge": @"1",
                                       @"ios_sound": @"default",
                                       };
    //
    NSError *error = nil;
    NSData *sendData = [NSJSONSerialization dataWithJSONObject:dictPush options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:sendData encoding:NSUTF8StringEncoding];
    //
    event.message = jsonString;
    
    [QBRequest createEvent:event successBlock:^(QBResponse *response, NSArray *events) {
        //
    } errorBlock:^(QBResponse *response) {
        //
    }];
}

@end