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


#pragma mark - Private chat notifications

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
    notification.text = @"Contact request";  // ⚠ contact request
    return notification;
}

- (void)sendNotification:(QBChatMessage *)notification completion:(void(^)(NSError *error, QBChatMessage *notification))completionBlock
{
    QBChatDialog *dialog = [self.chatDialogsService privateDialogWithOpponentID:notification.recipientID];
    NSAssert(dialog, @"Dialog not found. Please ");
    if (notification.cParamNotificationType == QMMessageNotificationTypeSendContactRequest) {
        notification.cParamDialogOccupantsIDs = dialog.occupantIDs;
    }
    
    __weak typeof(self) weakSelf = self;
    [self.messagesService sendPrivateMessage:notification toDialog:dialog persistent:YES completion:^(NSError *error) {
        
        if (!error) {
            [weakSelf.messagesService addMessageToHistory:notification withDialogID:dialog.ID];
            [dialog updateLastMessageInfoWithMessage:notification isMine:YES];
            if (completionBlock) completionBlock(nil, notification);
        } else {
            if (completionBlock) completionBlock(error, nil);
        }
    }];
//    [self sendPushContactRequestNotification:notification];
}


#pragma mark - Group chat notifications

- (void)sendGroupChatDialogDidCreateNotification:(QBChatMessage *)notification toChatDialog:(QBChatDialog *)chatDialog persistent:(BOOL)persistent completionBlock:(void(^)(QBChatMessage *))completion
{
    __weak typeof (self)weakSelf = self;
    void (^completionBlock)(NSError *) = ^(NSError *error) {
        if (!error) {
            [weakSelf.messagesService addMessageToHistory:notification withDialogID:chatDialog.ID];
            if (completion) completion(notification);
            return;
        }
        if (completion) completion(nil);
    };
    
    notification.cParamNotificationType = QMMessageNotificationTypeCreateGroupDialog;
    if (!persistent) {
        [self.messagesService sendPrivateMessage:notification toDialog:chatDialog persistent:persistent completion:completionBlock];
    } else {
        [self.messagesService sendGroupChatMessage:notification toDialog:chatDialog completion:completionBlock];
    }
}

- (void)sendGroupChatDialogDidUpdateNotification:(QBChatMessage *)notification toChatDialog:(QBChatDialog *)chatDialog completionBlock:(void(^)(QBChatMessage *))completion
{
    __weak typeof (self)weakSelf = self;
    notification.cParamNotificationType = QMMessageNotificationTypeUpdateGroupDialog;
    [self.messagesService sendGroupChatMessage:notification toDialog:chatDialog completion:^(NSError *error){
        if (!error) {
            [weakSelf.messagesService addMessageToHistory:notification withDialogID:chatDialog.ID];
            if (completion) completion(notification);
        }
    }];
}


#pragma mark - Push Notifications

- (void)sendPushContactRequestNotification:(QBChatMessage *)notification
{
    NSString *message = [QMChatUtils messageTextForPushWithNotification:notification];
    QBMEvent *event = [QBMEvent event];
    event.notificationType = QBMNotificationTypePush;
    event.usersIDs = [NSString stringWithFormat:@"%zd", notification.recipientID];
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