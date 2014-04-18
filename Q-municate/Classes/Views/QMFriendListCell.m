//
//  QMFriendListCell.m
//  Q-municate
//
//  Created by Igor Alefirenko on 25/02/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMFriendListCell.h"
#import "NSDateFormatter+SinceDateFormat.h"
#import "UIImageView+ImageWithBlobID.h"
#import "QMContactList.h"
#import "QMUtilities.h"


#define kUptimeInterval  300

@implementation QMFriendListCell


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)configureCellWithParams:(QBUUser *)user searchText:(NSString *)searchText indexPath:(NSIndexPath *)indexPath
{
    self.userImage.layer.cornerRadius = self.userImage.frame.size.width / 2;
    self.userImage.layer.borderWidth = 2.0f;
    self.userImage.layer.borderColor = [UIColor colorWithRed:1/215 green:1/216 blue:1/215 alpha:0.04].CGColor;   //215,216,215
    
    // cancel previous user's avatar loading
    [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget:self.userImage];

    // load avatar:
    if (user.website != nil) {
        [self.userImage setImageURL:[NSURL URLWithString:user.website]];
    } else if (user.blobID != 0) {
        [self.userImage loadImageWithBlobID:user.blobID];
    }
    self.userImage.layer.masksToBounds = YES;
    // full name
    self.fullName.attributedText = [[NSAttributedString alloc] initWithString:user.fullName];
    
    self.addToFriendsButton.tag = indexPath.row;
    self.addToFriendsButton.hidden =YES;
    
    BOOL isFriend = [[QMContactList shared] isFriend:user];
    if (!isFriend) {
        self.addToFriendsButton.hidden = NO;
    }
    
    
    // colour matching
    if (searchText != nil && searchText.length > 0) {
        NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithAttributedString:self.fullName.attributedText];
        [text addAttribute: NSForegroundColorAttributeName value:[UIColor redColor]
                     range:[[user.fullName lowercaseString] rangeOfString:[searchText lowercaseString]]];
        self.fullName.attributedText = text;
    }
    
    // activity
    NSDate *currentDate = [NSDate date];
    double timeInterval = [currentDate timeIntervalSinceDate:user.lastRequestAt];
    NSString *activity = nil;
    if (timeInterval <= kUptimeInterval) {
        activity = kStatusOnlineString;
        if (isFriend) {
            self.onlineCircle.hidden = NO;
        }
    } else {
        activity = kStatusOfflineString;
        self.onlineCircle.hidden = YES;
    }
    self.lastActivity.text = activity;
}

@end
