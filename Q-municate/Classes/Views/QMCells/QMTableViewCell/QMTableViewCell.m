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
}

- (void)setUserImageWithUrl:(NSURL *)userImageUrl {
    
    UIImage *placeholder = [UIImage imageNamed:@"upic-placeholder"];
    
    [self.qmImageView setImageWithURL:userImageUrl
                          placeholder:placeholder
                              options:SDWebImageContinueInBackground
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
