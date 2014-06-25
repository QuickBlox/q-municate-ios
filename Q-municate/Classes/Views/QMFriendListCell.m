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


- (void)awakeFromNib
{
    self.userImage.layer.cornerRadius = self.userImage.frame.size.width / 2;
    self.userImage.layer.borderWidth = 2.0f;
    self.userImage.layer.borderColor = [UIColor colorWithRed:1/215 green:1/216 blue:1/215 alpha:0.04].CGColor;   //215,216,215
    self.userImage.layer.masksToBounds = YES;
    self.userImage.crossfadeDuration = 0.0f;
}

- (void)configureCellWithParams:(QBUUser *)user searchText:(NSString *)searchText indexPath:(NSIndexPath *)indexPath
{
    [self.userImage setImage:[UIImage imageNamed:@"upic-placeholder"]];
    // load avatar:
    if (user.website != nil) {
        [self.userImage setImageURL:[NSURL URLWithString:user.website]];
    }
    // full name
	if (!user.fullName || !user.fullName.length) {
		NSLog(@"%@", user);
		self.fullName.text = kEmptyString;
	} else {
		self.fullName.text = user.fullName;
	}

    self.addToFriendsButton.tag = indexPath.row;
    
    BOOL isFriend = [[QMContactList shared] isFriend:user];
    self.addToFriendsButton.hidden = isFriend;

    
    // color matching
    if (searchText != nil && searchText.length > 0) {
        NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithAttributedString:self.fullName.attributedText];
        [text addAttribute: NSForegroundColorAttributeName value:[UIColor redColor]
                     range:[[user.fullName lowercaseString] rangeOfString:[searchText lowercaseString]]];
        self.fullName.attributedText = text;
    }
    
    // Online/Offline status:
    QBContactListItem *contactItem = [[QMContactList shared] contactItemFromContactListForOpponentID:user.ID];
    BOOL isOnline = contactItem.online;
    NSString *activity = nil;
    if (isOnline) {
        activity = kStatusOnlineString;
    } else {
        activity = kStatusOfflineString;
    }
    self.onlineCircle.hidden = isOnline;
    self.lastActivity.text = activity;
}

@end
