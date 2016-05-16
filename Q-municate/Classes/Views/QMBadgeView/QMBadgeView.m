//
//  QMBadgeView.m
//  Q-municate
//
//  Created by Andrey Ivanov on 01.04.15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import "QMBadgeView.h"

@interface QMBadgeView()

@property (strong, nonatomic) UIColor *badgeTextColor;
@property (strong, nonatomic) UIColor *badgeBGColor;
@property (strong, nonatomic) UIColor *borderColor;
@property (strong, nonatomic) UIColor *gradientB;
@property (strong, nonatomic) UIColor *gradientA;

@property (assign, nonatomic) BOOL glosEnabled;

@property (assign, nonatomic) BOOL innerShadowEnabled;
@property (assign, nonatomic) BOOL outedShadewEnabled;

@end

@implementation QMBadgeView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.backgroundColor = UIColor.clearColor;
    self.badgeTextColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f];
    self.badgeBGColor = [UIColor colorWithRed:0.063f green:0.353f blue:0.639f alpha:1.0f];
    self.borderColor = [UIColor colorWithRed: 0.219f green: 0.51f blue: 0.753f alpha: 1.0f];
    self.gradientB = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0];
    self.gradientA = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f];
    
    self.cornerRadius = self.frame.size.height/2;
    self.glosEnabled = NO;
    self.borderWidth = 0;
    self.badgeNumber = 0;
    
    self.layer.shouldRasterize = YES;
}

- (void)drawRect:(CGRect)rect {
    
    [self drawBadgeViewWithFrame:rect badgeNumber:self.badgeNumber];
}

- (void)drawBadgeViewWithFrame:(CGRect)frame
                   badgeNumber:(NSUInteger)badgeNumber {
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGRect badgeRect = CGRectMake(2.f/2.f, 2.f/2.f, frame.size.width - 2, frame.size.height - 2);
    
    UIBezierPath* badgePath = [UIBezierPath bezierPathWithRoundedRect: badgeRect cornerRadius:self.cornerRadius];
    
    if (self.outedShadewEnabled) {
        
        UIColor* outerShadow = UIColor.blackColor;
        CGSize outerShadowOffset = CGSizeMake(2, 2);
        CGFloat outerShadowBlurRadius = 2;
        
        CGContextSaveGState(context);
        CGContextSetShadowWithColor(context, outerShadowOffset, outerShadowBlurRadius, [outerShadow CGColor]);
        CGContextRestoreGState(context);
    }
    
    [self.badgeBGColor setFill];
    [badgePath fill];
    
    if (self.innerShadowEnabled) {
        
        UIColor* innerShadow = UIColor.blackColor;
        CGSize innerShadowOffset = CGSizeMake(2, 2);
        CGFloat innerShadowBlurRadius = 2;
        ////// badge Inner Shadow
        CGContextSaveGState(context);
        UIRectClip(badgePath.bounds);
        CGContextSetShadowWithColor(context, CGSizeZero, 0, NULL);
        
        CGContextSetAlpha(context, CGColorGetAlpha([innerShadow CGColor]));
        
        CGContextBeginTransparencyLayer(context, NULL);
        {
            UIColor* opaqueShadow = [innerShadow colorWithAlphaComponent: 1];
            CGContextSetShadowWithColor(context, innerShadowOffset, innerShadowBlurRadius, [opaqueShadow CGColor]);
            CGContextSetBlendMode(context, kCGBlendModeSourceOut);
            CGContextBeginTransparencyLayer(context, NULL);
            
            [opaqueShadow setFill];
            [badgePath fill];
            
            CGContextEndTransparencyLayer(context);
        }
        
        CGContextEndTransparencyLayer(context);
        CGContextRestoreGState(context);
        
    }
    
    [self.borderColor setStroke];
    badgePath.lineWidth = self.borderWidth;
    [badgePath stroke];
    NSMutableParagraphStyle* badgeStyle = NSMutableParagraphStyle.defaultParagraphStyle.mutableCopy;
    badgeStyle.alignment = NSTextAlignmentCenter;
    
    NSDictionary* badgeFontAttributes = @{
                                          NSFontAttributeName:[UIFont fontWithName: @"Helvetica"
                                                                              size:badgeRect.size.height * 0.69f],
                                          NSForegroundColorAttributeName: self.badgeTextColor,
                                          NSParagraphStyleAttributeName: badgeStyle
                                          };
    
    NSString *badgeText = [NSString stringWithFormat:@"%@",
                           badgeNumber > 99 ? @"99+" : @(badgeNumber)];
    [badgeText drawInRect:CGRectOffset(badgeRect,
                                       0,
                                       (CGRectGetHeight(badgeRect) - [badgeText boundingRectWithSize:badgeRect.size
                                                                                             options:NSStringDrawingUsesLineFragmentOrigin
                                                                                          attributes:badgeFontAttributes
                                                                                             context:nil].size.height) / 2)
           withAttributes:badgeFontAttributes];
    
    
    if (self.glosEnabled) {
        
        //// Gradient Declarations
        CGFloat gradientLocations[] = {0, 0.26f, 1.0f};
        CGGradientRef gradient = CGGradientCreateWithColors(colorSpace,
                                                            (__bridge CFArrayRef)@[(id)self.gradientA.CGColor,
                                                                                   (id)[UIColor colorWithRed:1 green:1 blue:1 alpha:0.5].CGColor,
                                                                                   (id)self.gradientB.CGColor],
                                                            gradientLocations);
        
        CGRect glosRect = badgeRect;
        
        UIBezierPath* glosPath = [UIBezierPath bezierPathWithRoundedRect:glosRect cornerRadius:self.cornerRadius];
        
        CGContextSaveGState(context);
        [glosPath addClip];
        
        CGContextDrawLinearGradient(context,
                                    gradient,
                                    CGPointMake(CGRectGetMidX(glosRect), CGRectGetMinY(glosRect)),
                                    CGPointMake(CGRectGetMidX(glosRect), CGRectGetMaxY(glosRect)),
                                    0);
        
        CGContextRestoreGState(context);
        CGGradientRelease(gradient);
    }
    
    // Cleanup
    CGColorSpaceRelease(colorSpace);
}

#pragma mark - Setters

- (void)setBadgeNumber:(NSUInteger)badgeNumber {
    
    if (self.hideOnZeroValue && badgeNumber == 0) {
        self.hidden = YES;
        return;
    }
    
    self.hidden = NO;
    
    if (_badgeNumber != badgeNumber) {
        
        _badgeNumber = badgeNumber;
        [self setNeedsDisplay];
    }
}

@end
