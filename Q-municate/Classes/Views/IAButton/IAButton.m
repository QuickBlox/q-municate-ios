//
//  IAButton.m
//  QBRTCChatSemple
//
//  Created by Andrey Ivanov on 16.12.14.
//  Copyright (c) 2014 QuickBlox Team. All rights reserved.
//

#import "IAButton.h"
@import QuartzCore;

const CGFloat kAnimationLength = 0.15;

@interface IAButton()

@property (nonatomic, assign) BOOL isPressed;
@property (nonatomic, strong) UIColor *backgroundDefaultColor;
@end

@implementation IAButton


- (instancetype)initWithCoder:(NSCoder *)coder {
    
    self = [super initWithCoder:coder];
    if (self) {
        self.exclusiveTouch = YES;
        self.layer.borderWidth = 1.0f;
        [self setDefaultStyles];
        self.backgroundDefaultColor = self.backgroundColor;
        self.clipsToBounds = YES;
    }
    return self;
}

- (void)setDefaultStyles {
    if( self.borderColor == nil ){
        self.borderColor = [UIColor colorWithWhite:0.352 alpha:0.560];
    }
    if( self.selectedColor == nil ){
        self.selectedColor = [UIColor colorWithWhite:1.000 alpha:0.600];
    }
    self.textColor = [UIColor whiteColor];
    self.hightlightedTextColor = [UIColor whiteColor];
    
    self.mainLabelFont = [UIFont fontWithName:@"HelveticaNeue-Thin" size:32];
    self.subLabelFont = [UIFont fontWithName:@"HelveticaNeue" size:10];
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    [self prepareApperance];
    [self performLayout];
}

- (void)drawRect:(CGRect)rect {
    
    [super drawRect:rect];
    [self prepareApperance];
}

- (void)prepareApperance {
    
    self.layer.borderColor = [self.borderColor CGColor];
}

- (void)performLayout {
    
    self.layer.cornerRadius = self.frame.size.height / 2.0;
}

- (void)setSelected:(BOOL)selected{
    [super setSelected:selected];
    [self tappedBegan];
    [self tappedEnded];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [super touchesBegan:touches withEvent:event];
    
    __weak __typeof(self)weakSelf = self;
    [UIView animateWithDuration:kAnimationLength
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         [weakSelf tappedBegan];
                     } completion:nil];
}

- (void)tappedBegan{
    [self setHighlighted:YES];
    self.backgroundColor = self.highlightedColor;
}

- (void)tappedEnded{
    [self setHighlighted:NO];
    if( self.selectedColor && self.selected ){
        self.backgroundColor = self.selectedColor;
    }
    else{
        self.backgroundColor = self.backgroundDefaultColor;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [super touchesEnded:touches withEvent:event];
    __weak __typeof(self)weakSelf = self;
    
    [UIView animateWithDuration:kAnimationLength
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         [weakSelf tappedEnded];
                 
     } completion:nil];
}

- (void)setHighlighted:(BOOL)highlighted {
    
    [super setHighlighted:highlighted];
}

#pragma mark -
#pragma mark - Default View Methods

- (UILabel *)standardLabel {
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.minimumScaleFactor = 1.0;
    
    return label;
}

@end
