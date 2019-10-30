//
//  QMCornerButton.m
//  Q-municate
//
//  Created by Injoit on 27.02.15.
//  Copyright © 2015 QuickBlox. All rights reserved.
//

#import "QMCornerButton.h"

@interface QMCornerButton ()

@property (strong, nonatomic) UIColor *bgColor;

@end

@implementation QMCornerButton

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.bgColor = self.backgroundColor;
}

- (void)setBorderWidth:(NSUInteger)borderWidth {
    
    _borderWidth = borderWidth;
    self.layer.borderWidth = borderWidth;
}

- (void)setBorderColor:(UIColor *)borderColor {
    
    _borderColor = borderColor;
    self.layer.borderColor = borderColor.CGColor;
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    
    _cornerRadius = cornerRadius;
    self.layer.cornerRadius = cornerRadius;
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    
    if (highlighted) {
        
        self.backgroundColor = self.highlightedColor;
    }
    else {
        
        self.backgroundColor = self.bgColor;
    }
}

@end
