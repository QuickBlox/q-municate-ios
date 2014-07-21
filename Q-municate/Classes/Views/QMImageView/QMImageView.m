//
//  QMImageView.m
//  Qmunicate
//
//  Created by Andrey on 27.06.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMImageView.h"


CGFloat kQMUserImageViewLineBorderWidth = 1.0;
CGFloat kQMUserImageViewSquareCornerRadius = 6;

@interface QMImageView()


@end

@implementation QMImageView

- (id)initWithImage:(UIImage *)image {
    self = [super initWithImage:image];
    
    if (self) {
        [self configure];
    }
    
    return self;
}

- (id)initWithImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage NS_AVAILABLE_IOS(3_0) {
    
    self = [super initWithImage:image highlightedImage:highlightedImage];
    if (self) {
        [self configure];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self configure];
}

- (void)configure {
    
    self.imageViewType = QMImageViewTypeNone;
    self.layer.masksToBounds = YES;
}

- (void)setImageViewType:(QMImageViewType)imageViewType {

    if (_imageViewType != imageViewType) {
        
        switch (imageViewType) {
                
            case QMImageViewTypeNone: [self applyDefaultTheme]; break;
            case QMImageViewTypeCircle: [self applyCircleTheme]; break;
            case QMImageViewTypeSquare: [self applySquareTheme]; break;
                
            default:
                break;
        }
    }
}

- (void)applyDefaultTheme {
    
    self.layer.borderWidth = 0;
    self.layer.borderColor = nil;
    self.layer.cornerRadius = 0;
}

- (void)applyCircleTheme {
    
    self.layer.borderWidth = kQMUserImageViewLineBorderWidth;
    self.layer.borderColor = [UIColor colorWithWhite:1.000 alpha:0.720].CGColor;
    self.layer.cornerRadius = self.frame.size.width / 2;
}

- (void)applySquareTheme {
    
    self.layer.borderWidth = kQMUserImageViewLineBorderWidth;
    self.layer.borderColor = [UIColor whiteColor].CGColor;
    self.layer.cornerRadius = kQMUserImageViewSquareCornerRadius;
}

@end
