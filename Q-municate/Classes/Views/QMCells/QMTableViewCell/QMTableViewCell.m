//
//  QMTableViewCell.m
//  Qmunicate
//
//  Created by Andrey Ivanov on 11.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMTableViewCell.h"
#import "QMImageView.h"

@interface QMTableViewCell()

@end

@implementation QMTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.qmImageView.imageViewType = QMImageViewTypeCircle;
    self.qmImageView.layer.cornerRadius = self.qmImageView.frame.size.width / 2;
    self.qmImageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.qmImageView.layer.borderWidth = 1.0f;
    self.qmImageView.layer.masksToBounds = YES;
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

@end
