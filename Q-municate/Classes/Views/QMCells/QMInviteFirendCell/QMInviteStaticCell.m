//
//  QMInviteFriendsStaticCell.m
//  Q-municate
//
//  Created by Igor Alefirenko on 25.03.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMInviteStaticCell.h"

@interface QMInviteStaticCell()

@property (weak, nonatomic) IBOutlet UILabel *badgeCounter;
@property (weak, nonatomic) IBOutlet UIImageView *activeCheckBox;

@end

@implementation QMInviteStaticCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.activeCheckBox.hidden = YES;
}

- (void)setBadgeCount:(NSUInteger)badgeCount {
    _badgeCount = badgeCount;

    self.badgeCounter.text = [NSString stringWithFormat:@"%tu", badgeCount];
}

- (void)setCheck:(BOOL)check {
    
    if (_check != check) {
        _check = check;
        self.activeCheckBox.hidden = !check;
    }
}

- (IBAction)pressCheckBox:(id)sender {

    self.check ^= 1;
    [self.delegate containerView:self didChangeState:sender];
}

@end
