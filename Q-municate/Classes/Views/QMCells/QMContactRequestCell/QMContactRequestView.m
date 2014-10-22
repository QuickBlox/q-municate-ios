//
//  QMContactRequestView.m
//  Q-municate
//
//  Created by Igor Alefirenko on 28/08/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMContactRequestView.h"
#import "QMImageView.h"
#import "QMUsersUtils.h"

@implementation QMContactRequestView


- (void)setUserData:(id)userData {
    if (![_userData isEqual:userData]) {
        _userData = userData;
    }
    
    QBUUser *user = userData;
    self.titleLabel.text = [NSString stringWithFormat:@"%@ would like to chat with you", (user.fullName.length == 0) ? @"Unknown" : user.fullName];
}

- (IBAction)rejectButtonPressed:(id)sender {
    if ([self.delegate respondsToSelector:@selector(contactRequestWasRejectedForUser:)]) {
        [self.delegate contactRequestWasRejectedForUser:self.userData];
    }
}

- (IBAction)acceptButtonPressed:(id)sender {
    if ([self.delegate respondsToSelector:@selector(contactRequestWasAcceptedForUser:)]) {
        [self.delegate contactRequestWasAcceptedForUser:self.userData];
    }
}

@end
