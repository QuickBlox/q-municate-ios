//
//  QMInviteFriendsCell.m
//  Q-municate
//
//  Created by Igor Alefirenko on 24.03.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMInviteFriendsCell.h"

#import "ABPerson.h"
#import "QMImageView.h"
#import "SVProgressHUD.h"

static double_t const kUptimeInterval = 300;

@implementation QMInviteFriendsCell

- (void)awakeFromNib {
    [super awakeFromNib];

    self.userImageView.imageViewType = QMImageViewTypeCircle;
}

- (void)configureCellWithParams:(ABPerson *)user {
    
    self.user = user;
    
    self.userImageView.image = user.image;
    
    self.fullNameLabel.text = [NSString stringWithFormat:@"%@ %@", user.firstName, user.lastName];
    self.statusLabel.text = @"Contact list";
//    self.activeCheckbox.hidden = !user.checked;
}

- (void)configureCellWithParamsForQBUser:(QBUUser *)user checked:(BOOL)checked {
    
    self.fullNameLabel.text = user.fullName;

    NSURL *url = [NSURL URLWithString:user.website];
    [self setUserImageWithUrl:url];
    NSDate *currentDate = [NSDate date];
    double timeInterval = [currentDate timeIntervalSinceDate:user.lastRequestAt];
    NSString *activity = (timeInterval <= kUptimeInterval) ? kStatusOnlineString : kStatusOfflineString;
    self.statusLabel.text = activity;
    self.activeCheckbox.hidden = !checked;
}

- (void)setUserImageWithUrl:(NSURL *)url {
    
    UIImage *placeholder = [UIImage imageNamed:@"upic-placeholder"];
    [self.userImageView setImageWithURL:url placeholderImage:placeholder];
}

@end
