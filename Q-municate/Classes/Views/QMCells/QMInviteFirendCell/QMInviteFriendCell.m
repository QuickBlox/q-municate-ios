//
//  QMInviteFriendsCell.m
//  Q-municate
//
//  Created by Igor Alefirenko on 24.03.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMInviteFriendCell.h"
#import "ABPerson.h"
#import "QMApi.h"

@interface QMInviteFriendCell()

@property (weak, nonatomic) IBOutlet UIImageView *activeCheckbox;

@end

@implementation QMInviteFriendCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.activeCheckbox.hidden = YES;
}

- (void)setUserData:(id)userData {
    
    [super setUserData:userData];
    
    if ([userData isKindOfClass:ABPerson.class]) {
        [self configureWithAdressaddressBookUser:userData];
    } else if ([userData conformsToProtocol:@protocol(FBGraphUser)]) {
        [self configureWithFBGraphUser:userData];
    } else if ([userData isKindOfClass:[QBUUser class]]) {

        QBUUser *user = userData;
        self.titleLabel.text = (user.fullName.length == 0) ? kEmptyString : user.fullName;
        NSURL *avatarUrl = [NSURL URLWithString:user.website];
        [self setUserImageWithUrl:avatarUrl];
    }
}

- (void)configureWithFBGraphUser:(NSDictionary<FBGraphUser> *)user {
    
    self.titleLabel.text = [NSString stringWithFormat:@"%@ %@", user.first_name, user.last_name];
    NSURL *url = [[QMApi instance] fbUserImageURLWithUserID:user.id];
    [self setUserImageWithUrl:url];
    self.descriptionLabel.text = @"Facebook";
}

- (void)configureWithAdressaddressBookUser:(ABPerson *)addressBookUser {
    
    self.titleLabel.text = addressBookUser.fullName;
    self.descriptionLabel.text = @"Contact list";
    
    UIImage *image = addressBookUser.image;
    [self setUserImage:image];
}

- (void)setCheck:(BOOL)check {
    
    if (_check != check) {
        _check = check;
        self.activeCheckbox.hidden = !check;
    }
}

#pragma mark - Actions

- (IBAction)pressCheckBox:(id)sender {

    self.check ^= 1;
    [self.delegate containerView:self didChangeState:sender];
}

@end
