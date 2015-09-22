//
//  QMChatNotificationCell.m
//  Q-municate
//
//  Created by Igor Alefirenko on 07.10.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMChatNotificationCell.h"
#import "QMMessage.h"
#import "QMChatUtils.h"
#import "QMApi.h"

@implementation QMChatNotificationCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setNotification:(QMMessage *)notification
{
    if (![_notification isEqual:notification]) {
        _notification = notification;
    }
    
    self.dateLabel.text = [[self formatter] stringFromDate:self.notification.dateSent];
    self.messageLabel.text = [QMChatUtils messageTextForNotification:self.notification];
}

- (NSString *)nameOfUser:(QBUUser *)user
{
    NSUInteger myID = [QMApi instance].currentUser.ID;
    return (user.ID == myID) ? @"You" : user.fullName;
}

- (NSDateFormatter *)formatter {
    
    static dispatch_once_t onceToken;
    static NSDateFormatter *_dateFormatter = nil;
    dispatch_once(&onceToken, ^{
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:@"HH:mm"];
    });
    
    return _dateFormatter;
}

@end
