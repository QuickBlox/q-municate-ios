//
//  QMChatViewCell.m
//  Q-municate
//
//  Created by Igor Alefirenko on 01/04/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMChatViewCell.h"
#import "NSDateFormatter+SinceDateFormat.h"
#import "QMUtilities.h"

@implementation QMChatViewCell


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configureCellWithMessage:(QBChatAbstractMessage *)message fromUser:(QBUUser *)user
{
    if (!user) {
        self.fullNameLabel.text = @"Unknown User";     // кастыль
    } else {
        self.fullNameLabel.text = user.fullName;
    }
	self.messageTextLabel.text = message.text;

	self.dateTimeLabel.text = [[QMUtilities shared].dateFormatter fullFormatPassedTimeFromDate:message.datetime];

	//changing height
	CGSize size = [QMChatViewCell getSizeForMessage:message.text];
	CGRect updatedFrame = CGRectMake(self.messageTextLabel.frame.origin.x, self.messageTextLabel.frame.origin.y, size.width, size.height);
	self.messageTextLabel.frame = updatedFrame;
}

+ (CGFloat)cellHeightForMessage:(NSString *)messageString
{
    CGSize size = [QMChatViewCell getSizeForMessage:messageString];
    return size.height + 5.0;
}

+ (CGSize)getSizeForMessage:(NSString *)messageString {
    CGSize constrainedSize = { 240.0, 10000.0 };
    NSDictionary *stringAttributes = [NSDictionary dictionaryWithObject:[UIFont systemFontOfSize:17.0f] forKey: NSFontAttributeName];
    CGSize size = [messageString boundingRectWithSize:constrainedSize options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin attributes:stringAttributes context:nil].size;

    return size;
}

@end
