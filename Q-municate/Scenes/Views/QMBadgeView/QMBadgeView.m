//
//  QMBadgeView.m
//  Q-municate
//
//  Created by Injoit on 01.04.15.
//  Copyright © 2015 QuickBlox. All rights reserved.
//

#import "QMBadgeView.h"

@interface QMBadgeView()

@property (strong, nonatomic) UIColor *badgeTextColor;
@property (strong, nonatomic) UIColor *badgeBGColor;
@property (strong, nonatomic) UIImageView *bgView;
@property (strong, nonatomic) UILabel *badge;

@end

@implementation QMBadgeView

@dynamic badgeText;

static UIImage *_bgViewImage = nil;

+ (UIImage *)circlieImageWithColor:(UIColor *)color {
    
    CGSize size = CGSizeMake(24, 24);
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillEllipseInRect(context, rect);
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    // End the image context
    UIGraphicsEndImageContext();
    
    return [resultImage stretchableImageWithLeftCapWidth:11
                                            topCapHeight:11];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _badgeTextColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f];
    _badgeBGColor = [UIColor colorWithRed:23.0f/255.0f green:208.0f/255.0f blue:75.f/255.0f alpha:1.0f];
    
    _bgView = [[UIImageView alloc] init];
    _bgView.frame = self.bounds;
    _bgView.autoresizingMask = UIViewAutoresizingFlexibleWidth |
    UIViewAutoresizingFlexibleHeight;
    [self addSubview:_bgView];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _bgViewImage = [QMBadgeView circlieImageWithColor:self.badgeBGColor];
    });
    
    _bgView.image = _bgViewImage;
    
    _badge = [[UILabel alloc] initWithFrame:self.bounds];
    _badge.textColor = self.badgeTextColor;
    _badge.textAlignment = NSTextAlignmentCenter;
    _badge.autoresizingMask = UIViewAutoresizingFlexibleWidth  | UIViewAutoresizingFlexibleHeight;
    
    [self addSubview:_badge];
    
    self.layer.opaque = YES;
}

//MARK: - Setters

- (void)setBadgeText:(NSString *)badgeText {
    _badge.text = badgeText;
}

- (NSString *)badgeText {
    return _badge.text;
}

@end
