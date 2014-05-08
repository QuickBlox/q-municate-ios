//
//  QMChatViewCell.m
//  Q-municate
//
//  Created by Igor Alefirenko on 01/04/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMChatViewCell.h"

@implementation QMChatViewCell


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configureCellWithMessage:(QBChatMessage *)chatMessage fromUser:(QBUUser *)user
{
	self.fullNameLabel.text = chatMessage.senderNick;
	self.messageTextLabel.text = [NSString stringWithFormat:@"%@", chatMessage.datetime];

	NSString *messageText = self.messageTextLabel.text = chatMessage.text;
	self.messageTextLabel.text = messageText;

	//changing height
	CGSize size = [QMChatViewCell getSizeForMessage:messageText];
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
