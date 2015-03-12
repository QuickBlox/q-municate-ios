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
        self.multipleTouchEnabled = NO;
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
    self.selectedColor = [UIColor colorWithWhite:1.000 alpha:0.600];
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
    
    
    CGFloat max = MAX(self.frame.size.height, self.frame.size.width) * 0.7;
    
    self.iconView.frame = CGRectMake(
                                     CGRectGetMidX(self.bounds) - (max / 2.0),
                                     CGRectGetMidY(self.bounds) - (max / 2.0),
                                     max,
                                     max);
    [self addSubview:self.iconView];
    
    
    self.layer.cornerRadius = self.frame.size.height / 2.0;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [super touchesBegan:touches withEvent:event];
    
    __weak __typeof(self)weakSelf = self;
    [UIView animateWithDuration:kAnimationLength
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         
                         CGFloat alpha = 1.0f;
                         
                         if (self.isPushed) {
                             
                             self.isPressed ^= YES;
                             alpha = self.isPressed ? 1.f : 0.f;
                         }
                         
                         [weakSelf setHighlighted:YES];
                         
                         weakSelf.backgroundColor = weakSelf.selectedColor;
                         
                     } completion:^(BOOL finished) {
                         
                     }];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [super touchesEnded:touches withEvent:event];
    __weak __typeof(self)weakSelf = self;
    
    [UIView animateWithDuration:kAnimationLength
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionAllowUserInteraction
                     animations:^
     {
         
         CGFloat alpha = 0.0f;
         
         if (self.isPushed) {
             
             alpha = self.isPressed ? 1.f : 0.f;
         }
         
         [weakSelf setHighlighted:NO];
         weakSelf.backgroundColor = weakSelf.backgroundDefaultColor;
         
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

#pragma mark - Setters

- (void)setIconView:(UIView *)iconView {
    
    if (![_iconView isEqual:iconView]) {
        
        iconView.userInteractionEnabled = NO;
        _iconView = iconView;
        
        [self setNeedsDisplay];
    }
}

@end
