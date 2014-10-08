//
//  QMChatNotificationCell.m
//  Q-municate
//
//  Created by Igor Alefirenko on 07.10.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMChatNotificationCell.h"
#import "QMApi.h"

@implementation QMChatNotificationCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setNotification:(QBChatMessage *)notification
{
    if (![_notification isEqual:notification]) {
        _notification = notification;
    }
    
}

- (NSString *)messageTextForNotification:(QBChatMessage *)notification
{
    NSString *messageText = nil;
    
    QBUUser *sender = [[QMApi instance] userWithID:notification.senderID];
    QBUUser *recipient = [[QMApi instance] userWithID:notification.recipientID];
    
    switch (notification.cParamNotificationType) {
        case QMMessageNotificationTypeSendContactRequest:
            messageText = @"%@ added %@ to contacts";
            break;
            
        default:
            break;
    }
    return messageText;
}

- (NSString *)nameOfUser:(QBUUser *)user
{
    NSUInteger myID = [QMApi instance].currentUser.ID;
    return (user.ID == myID) ? @"You" : user.fullName;
}






@end
