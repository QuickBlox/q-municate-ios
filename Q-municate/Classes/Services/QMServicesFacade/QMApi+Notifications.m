//
//  QMApi+Notifications.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 9/24/15.
//  Copyright © 2015 Quickblox. All rights reserved.
//

#import "QMApi.h"
#import "QMChatUtils.h"


@implementation QMApi (Notifications)


#pragma mark - Private chat notifications

- (void)sendContactRequestSendNotificationToUser:(QBUUser *)user completion:(void(^)(NSError *error, QBChatMessage *notification))completionBlock
{
    QBChatMessage *notification = [self notificationForUser:user];
    notification.messageType = QMMessageTypeContactRequest;
    [self sendNotification:notification completion:completionBlock];
}

- (void)sendContactRequestConfirmNotificationToUser:(QBUUser *)user completion:(void(^)(NSError *error, QBChatMessage *notification))completionBlock
{
    QBChatMessage *notification = [self notificationForUser:user];
    notification.messageType = QMMessageTypeAcceptContactRequest;
    [self sendNotification:notification completion:completionBlock];
}

- (void)sendContactRequestRejectNotificationToUser:(QBUUser *)user completion:(void(^)(NSError *error, QBChatMessage *notification))completionBlock
{
    QBChatMessage *notification = [self notificationForUser:user];
    notification.messageType = QMMessageTypeRejectContactRequest;
    [self sendNotification:notification completion:completionBlock];
}

- (void)sendContactRequestDeleteNotificationToUser:(QBUUser *)user completion:(void(^)(NSError *error, QBChatMessage *notification))completionBlock
{
    QBChatMessage *notification = [self notificationForUser:user];
    notification.messageType = QMMessageTypeDeleteContactRequest;
    [self sendNotification:notification completion:completionBlock];
}

- (QBChatMessage *)notificationForUser:(QBUUser *)user
{
    QBChatMessage *notification = [QBChatMessage message];
    notification.recipientID = user.ID;
    notification.senderID = self.currentUser.ID;
    notification.text = @"Contact request";  // contact request
    return notification;
}

- (void)sendNotification:(QBChatMessage *)notification completion:(void(^)(NSError *error, QBChatMessage *notification))completionBlock
{
    QBChatDialog *dialog = [self.chatService.dialogsMemoryStorage privateChatDialogWithOpponentID:notification.recipientID];
    NSAssert(dialog, @"Dialog not found");
    [notification updateCustomParametersWithDialog:[[QBChatDialog alloc] initWithDialogID:nil type:QBChatDialogTypePrivate]];
    if (notification.messageType == QMMessageTypeContactRequest) {
        notification.dialog.occupantIDs = dialog.occupantIDs;
    }
    
    [self.chatService sendMessage:notification toDialog:dialog save:YES completion:^(NSError *error) {
        //
        if (!error) {
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
    void (^completionBlock)(NSError *) = ^(NSError *error) {
        if (!error) {
            if (completion) completion(notification);
            return;
        }
        if (completion) completion(nil);
    };
    
    notification.messageType = QMMessageTypeCreateGroupDialog;
    [self.chatService sendMessage:notification toDialog:chatDialog save:YES completion:completionBlock];
}

- (void)sendGroupChatDialogDidUpdateNotification:(QBChatMessage *)notification toChatDialog:(QBChatDialog *)chatDialog completionBlock:(void(^)(QBChatMessage *))completion
{
    notification.messageType = QMMessageTypeUpdateGroupDialog;
    [self.chatService sendMessage:notification toDialog:chatDialog save:YES completion:^(NSError *error) {
        //
        if (!error) {
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
    //event.isDevelopmentEnvironment = ![QBSettings isUseProductionEnvironmentForPushNotifications];
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
