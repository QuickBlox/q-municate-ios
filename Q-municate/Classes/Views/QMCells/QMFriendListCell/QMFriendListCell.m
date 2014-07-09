//
//  QMFriendListCell.m
//  Q-municate
//
//  Created by Igor Alefirenko on 25/02/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMFriendListCell.h"
#import "QMImageView.h"

@interface QMFriendListCell()

@property (weak, nonatomic) IBOutlet QMImageView *userImage;
@property (weak, nonatomic) IBOutlet UILabel *fullName;
@property (weak, nonatomic) IBOutlet UILabel *lastActivity;
@property (weak, nonatomic) IBOutlet UIImageView *onlineCircle;
@property (weak, nonatomic) IBOutlet UIButton *addToFriendsButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicatorView;

@end

@implementation QMFriendListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.userImage.imageViewType = QMImageViewTypeCircle;
    self.addToFriendsButton.hidden = YES;
    self.onlineCircle.hidden = YES;
    self.lastActivity.text = kStatusOfflineString;
}

- (void)setUser:(QBUUser *)user {
    
    if (user != _user) {
        _user = user;
        
        UIImage *placeHolder = [UIImage imageNamed:@"upic-placeholder"];
        NSURL *avatarUrl = [NSURL URLWithString:user.website];
        [self.userImage setImageWithURL:avatarUrl placeholderImage:placeHolder];
        
        self.fullName.text = (user.fullName.length == 0) ? kEmptyString : user.fullName;
    }
}

- (void)setOnline:(BOOL)online {
    
    if (_online != online) {
        _online = online;
        
        NSString *activity = (online) ? kStatusOnlineString : kStatusOfflineString;
        self.onlineCircle.hidden = !online;
        self.lastActivity.text = activity;
    }
}

- (void)setSearchText:(NSString *)searchText {
    
    _searchText = searchText;
    if (_searchText.length > 0) {
        
        NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithAttributedString:self.fullName.attributedText];
        [text addAttribute: NSForegroundColorAttributeName
                     value:[UIColor redColor]
                     range:[self.user.fullName.lowercaseString rangeOfString:searchText.lowercaseString]];
        
        self.fullName.attributedText = text;
    }
}

- (void)setIsFriend:(BOOL)isFriend {
    
    if (isFriend != _isFriend) {
        _isFriend = isFriend;
        self.addToFriendsButton.hidden = isFriend;
    }
}

#pragma mark - Actions

- (IBAction)pressAddBtn:(UIButton *)sender {
    
    if ([self.delegate respondsToSelector:@selector(friendListCell:pressAddBtn:)]) {
        [self.delegate friendListCell:self pressAddBtn:sender];
    }
}

@end
