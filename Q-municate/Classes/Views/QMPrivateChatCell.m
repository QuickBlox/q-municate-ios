//
//  QMPrivateChatCell.m
//  Q-municate
//
//  Created by Igor Alefirenko on 27/05/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMPrivateChatCell.h"
#import "QMContactList.h"
#import "UIImageView+ImageWithBlobID.h"
#import "NSDateFormatter+SinceDateFormat.h"
#import "QMUtilities.h"

@implementation QMPrivateChatCell


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
//
//- (void)configureCellWithMessage:(QBChatAbstractMessage *)message fromUser:(QBUUser *)user
//{
//    self.myAvatarView.layer.cornerRadius = self.myAvatarView.frame.size.width / 2;
//    self.myAvatarView.layer.borderWidth = 2.0f;
//    self.myAvatarView.layer.borderColor = [UIColor colorWithRed:1/215 green:1/216 blue:1/215 alpha:0.04].CGColor;   //215,216,215
//    self.myAvatarView.layer.masksToBounds = YES;
//    
//    self.opponentAvatarView.layer.cornerRadius = self.opponentAvatarView.frame.size.width / 2;
//    self.opponentAvatarView.layer.borderWidth = 2.0f;
//    self.opponentAvatarView.layer.borderColor = [UIColor colorWithRed:1/215 green:1/216 blue:1/215 alpha:0.04].CGColor;   //215,216,215
//    self.opponentAvatarView.layer.masksToBounds = YES;
//    
//    // if message is mine:
//    if (user.ID == [QMContactList shared].me.ID) {
//        
//        self.myAvatarView.crossfadeDuration = 0.0f;
//        self.myAvatarView.image = [UIImage imageNamed:@"upic-placeholder"];
//        self.myAvatarView.hidden = NO;
//        self.opponentAvatarView.hidden = YES;
//        self.datetimeLabel.textAlignment = NSTextAlignmentLeft;
//        self.backgroundColor = [UIColor whiteColor];
//        
//        // load image:
//        if (user.website != nil) {
//            [self.myAvatarView setImageURL:[NSURL URLWithString:user.website]];
//        } else if (user.blobID > 0) {
//            [self.myAvatarView loadImageWithBlobID:user.blobID];
//        }
//    } else {
//        
//        self.opponentAvatarView.crossfadeDuration = 0.0f;
//        self.opponentAvatarView.image = [UIImage imageNamed:@"upic-placeholder"];
//        self.myAvatarView.hidden = YES;
//        self.opponentAvatarView.hidden = NO;
//        self.datetimeLabel.textAlignment = NSTextAlignmentRight;
//        self.backgroundColor = [UIColor colorWithRed:62/255.0 green:136/255.0 blue:203/255.0 alpha:0.09];
//        
//        if (user.website != nil) {
//            [self.opponentAvatarView setImageURL:[NSURL URLWithString:user.website]];
//        } else if (user.blobID > 0) {
//            [self.opponentAvatarView loadImageWithBlobID:user.blobID];
//        }
//    }
//    // text:
//    self.messageLabel.text = message.text;
//    // date time:
//    self.datetimeLabel.text = [[QMUtilities shared].dateFormatter fullFormatPassedTimeFromDate:message.datetime];
//    
//    //changing height
//	CGSize size = [QMPrivateChatCell getSizeForMessage:message];
//	CGRect updatedFrame = CGRectMake(self.messageLabel.frame.origin.x, self.messageLabel.frame.origin.y, self.messageLabel.frame.size.width, size.height);
//	self.messageLabel.frame = updatedFrame;
////    [self layoutIfNeeded];
//}
//
//+ (CGFloat)cellHeightForMessage:(QBChatAbstractMessage *)message
//{
//    CGSize size = [QMPrivateChatCell getSizeForMessage:message];
//    if (size.height <21) {      // single line of text:
//        return 20.0f + 25.0f +9;
//    }                           // >1 lines of text:
//    return size.height + 25.0;
//}
//
//+ (CGSize)getSizeForMessage:(QBChatAbstractMessage *)message {
//    CGSize constrainedSize = { 203.0, 10000.0 };
//    NSDictionary *stringAttributes = [NSDictionary dictionaryWithObject:[UIFont systemFontOfSize:17.0f] forKey: NSFontAttributeName];
//    CGSize size = [message.text boundingRectWithSize:constrainedSize options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin attributes:stringAttributes context:nil].size;
//    
//    return size;
//}

@end
