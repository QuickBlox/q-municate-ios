//
//  QMInviteFriendsCell.m
//  Q-municate
//
//  Created by Igor Alefirenko on 24.03.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMInviteFriendsCell.h"
#import "QMPerson.h"
#import "UIImageView+ImageWithBlobID.h"
#import <AsyncImageView.h>


static double_t const kUptimeInterval = 300;


@implementation QMInviteFriendsCell


- (void)awakeFromNib
{
    // cancel previous user's avatar loading
//    [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget:self.userImageView];
    [self.userImageView setImage:[UIImage imageNamed:@"upic-placeholder"]];
    
    self.userImageView.layer.cornerRadius = self.userImageView.frame.size.width / 2;
    self.userImageView.layer.borderWidth = 2.0f;
    self.userImageView.layer.borderColor = [UIColor colorWithRed:1/215 green:1/216 blue:1/215 alpha:0.04].CGColor;   //215,216,215
    self.userImageView.crossfadeDuration = 0.0f;
    self.userImageView.layer.masksToBounds = YES;
}

- (void)configureCellWithParams:(QMPerson *)user
{
    self.user = user;

    if (self.user.imageURL != nil) {
        [self.userImageView setImageURL:[NSURL URLWithString:user.imageURL]];
    } else {
		if (self.user.avatarImage) {
		    self.userImageView.image = self.user.avatarImage;
		} else {
			[self.userImageView setImage:[UIImage imageNamed:@"upic-placeholder"]];
		}
	}
    
    self.userImageView.layer.masksToBounds = YES;
    // full name
    self.fullNameLabel.text = user.fullName;
    // status
    self.statusLabel.text = user.status;
    
    if (user.checked) {
        self.activeCheckbox.hidden = NO;
    } else {
        self.activeCheckbox.hidden = YES;
    }
}

- (void)configureCellWithParamsForQBUser:(QBUUser *)user checked:(BOOL)checked
{
    // full name
    self.fullNameLabel.text = user.fullName;
    
    // avatar:
    if (user.website != nil) {
        [self.userImageView setImageURL:[NSURL URLWithString:user.website]];
    }
    
    // activity
    NSDate *currentDate = [NSDate date];
    double timeInterval = [currentDate timeIntervalSinceDate:user.lastRequestAt];
    
    NSString *activity = nil;
    if (timeInterval <= kUptimeInterval) {
        activity = kStatusOnlineString;
    } else {
        activity = kStatusOfflineString;
    }
    self.statusLabel.text = activity;
    
    if (checked) {
        self.activeCheckbox.hidden = NO;
    } else {
        self.activeCheckbox.hidden = YES;
    }
}

@end
