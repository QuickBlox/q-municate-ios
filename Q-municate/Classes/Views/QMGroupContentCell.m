//
//  QMGroupContentCell.m
//  Q-municate
//
//  Created by Igor Alefirenko on 30/05/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMGroupContentCell.h"
#import "UIImageView+ImageWithBlobID.h"
#import "QMUtilities.h"

@implementation QMGroupContentCell


- (void)awakeFromNib
{
//    // Initialization code
//    self.avatarView.layer.cornerRadius = self.avatarView.frame.size.width / 2;
//    self.avatarView.layer.borderWidth = 2.0f;
//    self.avatarView.layer.borderColor = [UIColor colorWithRed:1/215 green:1/216 blue:1/215 alpha:0.04].CGColor;   //215,216,215
//    self.avatarView.layer.masksToBounds = YES;
//    self.avatarView.crossfadeDuration = 0.0f;
}

- (void)configureCellWithMessage:(QBChatAbstractMessage *)message fromUser:(QBUUser *)user
{
    #warning image
//    self.avatarView.image = [UIImage imageNamed:@"upic-placeholder"];
//    
//    // avatar
//    if (user.website != nil) {
//        [self.avatarView setImageURL:[NSURL URLWithString:user.website]];
//    } else if (user.blobID != 0) {
//        [self.avatarView loadImageWithBlobID:user.blobID];
//    }
//    
//    // fullname:
//    self.fullNameLabel.text = user.fullName;
//    
//    // date time:
//    self.datetimeLabel.text = [[QMUtilities shared].dateFormatter fullFormatPassedTimeFromDate:message.datetime];
//    
//    // shared image:
//    QBChatAttachment *attach = message.attachments[0];
//    if ([attach.type isEqualToString:@"photo"]) {
//        if (attach.url != nil) {
//            [self.contentImageView setImageURL:[NSURL URLWithString:attach.url]];
//        } else if (attach.ID != nil) {
//            [self.contentImageView loadImageWithBlobID:[attach.ID integerValue]];
//        }
//    }
}

@end
