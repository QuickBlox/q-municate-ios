//
//  QMTableViewCell.m
//  Qmunicate
//
//  Created by Andrey on 11.07.14.
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
    
    UIImage *placeHolder = [UIImage imageNamed:@"upic-placeholder"];
    [self.qmImageView sd_setImageWithURL:userImageUrl placeholderImage:placeHolder];
}

- (void)setUserImage:(UIImage *)image {
    if (!image) {
        image = [UIImage imageNamed:@"upic-placeholder"];
    }
    self.qmImageView.image = image;
}

@end
