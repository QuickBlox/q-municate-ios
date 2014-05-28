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
#import "UIImageView+ImageWithBlobID.h"

@implementation QMChatViewCell


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configureCellWithMessage:(QBChatAbstractMessage *)message fromUser:(QBUUser *)user
{
    self.avatarView.layer.cornerRadius = self.avatarView.frame.size.width / 2;
    self.avatarView.layer.borderWidth = 2.0f;
    self.avatarView.layer.borderColor = [UIColor colorWithRed:1/215 green:1/216 blue:1/215 alpha:0.04].CGColor;   //215,216,215
    self.avatarView.layer.masksToBounds = YES;
    self.avatarView.crossfadeDuration = 0.0f;
    
    [self.avatarView setImage:[UIImage imageNamed:@"upic_placeholderr"]];
    
    if (!user) {
        self.fullNameLabel.text = @"Unknown User";     // кастыль
    } else {
        self.fullNameLabel.text = user.fullName;
    }
    
    // load image:
    if (user.website != nil) {
        [self.avatarView setImageURL:[NSURL URLWithString:user.website]];
    } else if (user.blobID > 0) {
        [self.avatarView loadImageWithBlobID:user.blobID];
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
