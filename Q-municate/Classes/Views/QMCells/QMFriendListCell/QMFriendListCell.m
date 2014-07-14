//
//  QMFriendListCell.m
//  Q-municate
//
//  Created by Ivanov Andrey on 25/02/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMFriendListCell.h"
#import "QMImageView.h"

@interface QMFriendListCell()

@property (weak, nonatomic) IBOutlet UIImageView *onlineCircle;
@property (weak, nonatomic) IBOutlet UIButton *addToFriendsButton;

@end

@implementation QMFriendListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.addToFriendsButton.hidden = NO;
    self.onlineCircle.hidden = YES;
}

- (void)setOnline:(BOOL)online {
    
    if (_online != online) {
        _online = online;
        
        self.onlineCircle.hidden = !online;
    }
    
//    NSString *activity = (online) ? kStatusOnlineString : kStatusOfflineString;
//    self.lastActivity.text = activity;
}


- (void)setSearchText:(NSString *)searchText {
    
    _searchText = searchText;
    if (_searchText.length > 0) {
        
        QBUUser *user = self.userData;
        NSString *fullName = user.fullName;
        
        NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:fullName];
        [text addAttribute: NSForegroundColorAttributeName
                     value:[UIColor redColor]
                     range:[fullName.lowercaseString rangeOfString:searchText.lowercaseString]];
        
        self.titleLabel.attributedText = text;
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
