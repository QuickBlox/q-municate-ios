//
//  QMUserCell.m
//  Qmunicate
//
//  Created by Andrey on 09.07.14.
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

- (void)setUser:(QBUUser *)user {
    
    if (user != _user) {
        _user = user;
        
        self.titleLabel.text = (user.fullName.length == 0) ? kEmptyString : user.fullName;
        NSURL *avatarUrl = [NSURL URLWithString:user.website];
        [self setUserImageWithUrl:avatarUrl];
    }
}


@end
