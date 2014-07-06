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
#import "QMUsersService.h"
#import "QMUtilities.h"
#import "QMImageView.h"

@implementation QMFriendListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.userImage.imageViewType = QMImageViewTypeCircle;
}

- (void)configureCellWithParams:(QBUUser *)user searchText:(NSString *)searchText indexPath:(NSIndexPath *)indexPath {
    
    UIImage *placeHolder = [UIImage imageNamed:@"upic-placeholder"];
    NSURL *avatarUrl = [NSURL URLWithString:user.website];
    [self.userImage setImageWithURL:avatarUrl placeholderImage:placeHolder];
    
    self.fullName.text = (user.fullName.length == 0) ? kEmptyString : user.fullName;

    self.addToFriendsButton.tag = indexPath.row;
#warning me.iD
#warning QMContactList shared
//    BOOL isFriend = [[QMContactList shared] isFriend:user];
//    self.addToFriendsButton.hidden = isFriend;
//
//    
//    // color matching
//    if (searchText != nil && searchText.length > 0) {
//        NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithAttributedString:self.fullName.attributedText];
//        [text addAttribute: NSForegroundColorAttributeName value:[UIColor redColor]
//                     range:[[user.fullName lowercaseString] rangeOfString:[searchText lowercaseString]]];
//        self.fullName.attributedText = text;
//    }
//    
//    // Online/Offline status:
//    QBContactListItem *contactItem = [[QMContactList shared] contactItemFromContactListForOpponentID:user.ID];
//    BOOL isOnline = contactItem.online;
//    NSString *activity = nil;
//    if (isOnline) {
//        activity = kStatusOnlineString;
//    } else {
//        activity = kStatusOfflineString;
//    }
//    self.onlineCircle.hidden = !isOnline;
//    self.lastActivity.text = activity;
}

@end
