//
//  QMChatInvitationCell.m
//  Q-municate
//
//  Created by Igor Alefirenko on 22/05/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMChatInvitationCell.h"
#import "NSDateFormatter+SinceDateFormat.h"
#import "QMUtilities.h"

@implementation QMChatInvitationCell

- (void)configureCellWithMessage:(QBChatAbstractMessage *)message
{
    self.dateTimeLabel.text = [[QMUtilities shared].dateFormatter fullFormatPassedTimeFromDate:message.datetime];
    self.messageLabel.text = message.text;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
