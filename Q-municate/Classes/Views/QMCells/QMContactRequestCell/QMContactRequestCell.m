//
//  QMContactRequestCell.m
//  Q-municate
//
//  Created by Igor Alefirenko on 28/08/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMContactRequestCell.h"
#import "QMUsersUtils.h"

@implementation QMContactRequestCell


- (void)setUserData:(id)userData {
    [super setUserData:userData];
    
    QBUUser *user = userData;
    self.titleLabel.text = (user.fullName.length == 0) ? @"" : user.fullName;
    NSURL *avatarUrl = [QMUsersUtils userAvatarURL:user];
    [self setUserImageWithUrl:avatarUrl];
}

- (IBAction)rejectButtonPressed:(id)sender {
    if ([self.delegate respondsToSelector:@selector(usersListCell:requestWasAccepted:)]) {
        [self.delegate usersListCell:self requestWasAccepted:NO];
    }
}

- (IBAction)acceptButtonPressed:(id)sender {
    if ([self.delegate respondsToSelector:@selector(usersListCell:requestWasAccepted:)]) {
        [self.delegate usersListCell:self requestWasAccepted:YES];
    }
}

@end
