//
//  QMContactRequestCell.m
//  Q-municate
//
//  Created by Igor Alefirenko on 28/08/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMContactRequestCell.h"
#import "QMApi.h"

@interface QMContactRequestCell()

@property (nonatomic, strong) QBUUser *opponent;

@end


@implementation QMContactRequestCell


- (void)setNotification:(QMMessage *)notification
{
    if (![_notification isEqual:notification]) {
        _notification = notification;
    }
    self.opponent = [[QMApi instance] userWithID:notification.senderID];
    self.fullNameLabel.text = notification.text;
}


- (IBAction)rejectButtonPressed:(id)sender {
    if ([self.delegate respondsToSelector:@selector(contactRequestWasRejectedForUser:)]) {
        [self.delegate contactRequestWasRejectedForUser:self.opponent];
    }
}

- (IBAction)acceptButtonPressed:(id)sender {
    if ([self.delegate respondsToSelector:@selector(contactRequestWasAcceptedForUser:)]) {
        [self.delegate contactRequestWasAcceptedForUser:self.opponent];
    }
}

@end
