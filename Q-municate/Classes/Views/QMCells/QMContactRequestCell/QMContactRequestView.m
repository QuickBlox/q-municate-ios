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

- (void)awakeFromNib {
    self.qmImageView.imageViewType = QMImageViewTypeCircle;
}

- (void)setUserImageWithUrl:(NSURL *)userImageUrl {
    
    UIImage *placeholder = [UIImage imageNamed:@"upic-placeholder"];
    
    [self.qmImageView setImageWithURL:userImageUrl
                          placeholder:placeholder
                              options:SDWebImageHighPriority
                             progress:^(NSInteger receivedSize, NSInteger expectedSize) {}
                       completedBlock:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {}];
}

- (void)setUserImage:(UIImage *)image withKey:(NSString *)key {
    
    if (!image) {
        image = [UIImage imageNamed:@"upic-placeholder"];
    }
    
    [self.qmImageView sd_setImage:image withKey:key];
}

- (void)setUserData:(id)userData {
    if (![_userData isEqual:userData]) {
        _userData = userData;
    }
    
    QBUUser *user = userData;
    self.titleLabel.text = (user.fullName.length == 0) ? @"" : user.fullName;
    NSURL *avatarUrl = [QMUsersUtils userAvatarURL:user];
    [self setUserImageWithUrl:avatarUrl];
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
