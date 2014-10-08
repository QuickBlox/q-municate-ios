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


@implementation QMApi (Notifications)


- (void)sendContactRequestSendNotificationToUser:(QBUUser *)user completion:(void(^)(NSError *error))completionBlock
{
    QBChatMessage *notification = [self notificationForUser:user];
    notification.cParamNotificationType = QMMessageNotificationTypeSendContactRequest;
    [self sendNotification:notification completion:completionBlock];
}

- (void)sendContactRequestConfirmNotificationToUser:(QBUUser *)user completion:(void(^)(NSError *error))completionBlock
{
    QBChatMessage *notification = [self notificationForUser:user];
    notification.cParamNotificationType = QMMessageNotificationTypeConfirmContactRequest;
    [self sendNotification:notification completion:completionBlock];
}

- (void)sendContactRequestRejectNotificationToUser:(QBUUser *)user completion:(void(^)(NSError *error))completionBlock
{
    QBChatMessage *notification = [self notificationForUser:user];
    notification.cParamNotificationType = QMMessageNotificationTypeRejectContactRequest;
    [self sendNotification:notification completion:completionBlock];
}

- (void)sendContactRequestDeleteNotificationToUser:(QBUUser *)user completion:(void(^)(NSError *error))completionBlock
{
    QBChatMessage *notification = [self notificationForUser:user];
    notification.cParamNotificationType = QMMessageNotificationTypeDeleteContactRequest;
    [self sendNotification:notification completion:completionBlock];
}

- (QBChatMessage *)notificationForUser:(QBUUser *)user
{
    QBChatMessage *notification = [QBChatMessage message];
    notification.recipientID = user.ID;
    return notification;
}

- (void)sendNotification:(QBChatMessage *)notification completion:(void(^)(NSError *error))completionBlock
{
    QBChatDialog *dialog = [self.chatDialogsService privateDialogWithOpponentID:notification.recipientID];
    NSAssert(dialog, @"Dialog not found. Please ");
    [self.messagesService sendMessage:notification withDialogID:dialog.ID saveToHistory:YES completion:completionBlock];
}

@end