//
//  QMGroupDetailsCell.m
//  Qmunicate
//
//  Created by Igor Alefirenko on 14/06/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMGroupDetailsCell.h"

@implementation QMGroupDetailsCell


- (void)awakeFromNib
{
//    self.avatarView.layer.cornerRadius = self.avatarView.frame.size.width / 2;
//    self.avatarView.layer.borderWidth = 2.0f;
//    self.avatarView.layer.borderColor = [UIColor colorWithRed:1/215 green:1/216 blue:1/215 alpha:0.04].CGColor;   //215,216,215
//    self.avatarView.layer.masksToBounds = YES;
//    self.avatarView.crossfadeDuration = 0.0f;
//    [self.avatarView setImage:[UIImage imageNamed:@"upic-placeholder"]];
}

- (void)configureCellWithUser:(QBUUser *)user online:(BOOL)isOnline
{
    // avatar:
//    if (user.website != nil) {
//        [self.avatarView setImageURL:[NSURL URLWithString:user.website]];
//    }
    
    // full name:
    self.fullNameLabel.text = user.fullName;
    
    // online status:
    if (isOnline) {
        self.statusLabel.text = @"Online";
        self.onlineCircle.hidden = NO;
    } else {
        self.statusLabel.text = @"Offline";
        self.onlineCircle.hidden = YES;
    }
}


@end
