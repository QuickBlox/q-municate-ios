//
//  QMNotificationManager.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 3/26/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMNotificationManager.h"
#import "QMCore.h"

@interface QMNotificationManager ()

@property (weak, nonatomic) QMCore <QMServiceManagerProtocol>*serviceManager;

@end

@implementation QMNotificationManager

@dynamic serviceManager;

#pragma mark - Instances

- (QBChatMessage *)contactRequestNotificationForUser:(QBUUser *)user {
    
    QBChatMessage *notification = notificationForUser(user);
    notification.messageType = QMMessageTypeContactRequest;
    
    return notification;
}

- (QBChatMessage *)removeContactNotificationForUser:(QBUUser *)user {
    
    QBChatMessage *notification = notificationForUser(user);
    notification.messageType = QMMessageTypeDeleteContactRequest;
    
    return notification;
}

#pragma mark - Helpers

static inline QBChatMessage *notificationForUser(QBUUser *user) {
    
    QBChatMessage *notification = [QBChatMessage message];
    notification.recipientID = user.ID;
    notification.text = kQMContactRequestNotificationMessage;
    notification.dateSent = [NSDate date];
    
    return notification;
}

@end
