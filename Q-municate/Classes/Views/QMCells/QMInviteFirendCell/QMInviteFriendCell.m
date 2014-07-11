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
@property (strong, nonatomic) ABPerson *addressBookUser;

@end

@implementation QMInviteFriendCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.activeCheckbox.hidden = YES;
}

- (void)setAddressBookUser:(ABPerson *)addressBookUser {
    
    if (_addressBookUser != addressBookUser) {
        _addressBookUser = addressBookUser;
        
        self.titleLabel.text = addressBookUser.fullName;
        self.descriptionLabel.text = @"Contact list";
        
        UIImage *image = self.addressBookUser.image;
        [self setUserImage:image];
    }
}

- (void)setUserData:(id)userData checked:(BOOL)checked {

    if ([userData isKindOfClass:ABPerson.class]) {
        [self addressBookUser:userData checked:checked];
    } else if ([userData conformsToProtocol:@protocol(FBGraphUser)]) {
        [self setFBGraphUser:userData checked:checked];
    }
}

- (void)setFBGraphUser:(NSDictionary<FBGraphUser> *)user checked:(BOOL)checked {
    
    self.titleLabel.text = [NSString stringWithFormat:@"%@ %@", user.first_name, user.last_name];
    NSURL *url = [[QMApi instance] fbUserImageURLWithUserID:user.id];
    [self setUserImageWithUrl:url];
    self.descriptionLabel.text = @"Facebook";
    self.check = checked;
}

- (void)setUser:(QBUUser *)user checked:(BOOL)checked {
    
    self.user = user;
    self.check = checked;
}

- (void)addressBookUser:(ABPerson *)addressBookUser checked:(BOOL)checked {
    
    self.addressBookUser = addressBookUser;
    self.check = checked;
}

- (void)setCheck:(BOOL)check {
    
    if (_check != check) {
        _check = check;
        self.activeCheckbox.hidden = !check;
    }
}

#pragma mark - Actions

- (IBAction)pressCheckBox:(id)sender {
    
    [self.delegate containerView:self didChangeState:sender];
}

@end
