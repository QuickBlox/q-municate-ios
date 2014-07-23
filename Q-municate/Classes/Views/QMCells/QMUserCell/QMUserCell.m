//
//  QMUserCell.m
//  Qmunicate
//
//  Created by Andrey Ivanov on 09.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMUserCell.h"
#import "QMImageView.h"

@interface QMUserCell()

@end

@implementation QMUserCell

- (void)awakeFromNib {
    
    [super awakeFromNib];
    self.descriptionLabel.text = kStatusOfflineString;
}

- (void)setUserData:(id)userData {
    
    if (_userData != userData) {
        _userData = userData;
        
        if ([_userData isKindOfClass:[QBUUser class]]) {
            [self configureWihtUser:_userData];
        }
    }
}

- (void)configureWihtUser:(QBUUser *)user {
    
    self.titleLabel.text = (user.fullName.length == 0) ? kEmptyString : user.fullName;
    NSURL *avatarUrl = [NSURL URLWithString:user.website];
    [self setUserImageWithUrl:avatarUrl];

}

@end
