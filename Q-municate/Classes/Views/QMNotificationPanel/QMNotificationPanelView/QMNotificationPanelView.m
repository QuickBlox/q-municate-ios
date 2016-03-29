//
//  QMNotificationPanelView.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 3/26/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMNotificationPanelView.h"
#import "QMNotificationPanelUtils.h"

static const CGFloat kQMVerticalSpace = 8.0f;
static const CGFloat kQMHorizontalSpace = 8.0f;
static const CGFloat kQMIconSize = 26.0f;

@interface QMNotificationPanelView ()

@property (assign, nonatomic) QMNotificationPanelType *notificationPanelType;

@property (strong, nonatomic) UILabel *textLabel;

@property (strong, nonatomic) UIVisualEffectView *visualEffectView;
@property (strong, nonatomic) UIView *bgColorView;

@end

@implementation QMNotificationPanelView

#pragma mark - Construction

- (instancetype)initWithFrame:(CGRect)frame notificationPanelType:(QMNotificationPanelType)notificationPanelType {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        [self configureBlurWithFrame:frame backgroundColor:color(notificationPanelType)];
        
        [self configureIconWithNotificationType:notificationPanelType];
        
        [self configureTextLabelWithFrame:frame];
    }
    
    return self;
}

- (void)configureBlurWithFrame:(CGRect)frame backgroundColor:(UIColor *)backgroundColor {
    
    // blur effect
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    _visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    _visualEffectView.frame = frame;
    // Background color
    _bgColorView = [[UIView alloc] initWithFrame:frame];
    _bgColorView.backgroundColor = backgroundColor;
    [_visualEffectView.contentView addSubview:_bgColorView];
    [self addSubview:_visualEffectView];
}

- (void)configureIconWithNotificationType:(QMNotificationPanelType)notificationPanelType {
    
    if (notificationPanelType == QMNotificationPanelTypeLoading) {
        
        // init activity indicator
        UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(kQMVerticalSpace, kQMHorizontalSpace, kQMIconSize, kQMIconSize)];
        activityIndicatorView.backgroundColor = clearColor();
        [activityIndicatorView startAnimating];
        [self addSubview:activityIndicatorView];
    }
    else {
        
        // init image view
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(kQMVerticalSpace, kQMHorizontalSpace, kQMIconSize, kQMIconSize)];
        imageView.backgroundColor = clearColor();
        imageView.image = image(notificationPanelType);
        [self addSubview:imageView];
    }
}

- (void)configureTextLabelWithFrame:(CGRect)frame {
    // init text label
    CGFloat textLabelX = kQMVerticalSpace + kQMIconSize + kQMVerticalSpace;
    _textLabel = [[UILabel alloc] initWithFrame:CGRectMake(textLabelX, kQMHorizontalSpace, frame.size.width - textLabelX - kQMHorizontalSpace, 26.0f)];
    _textLabel.userInteractionEnabled = YES;
    _textLabel.textColor = whiteColor();
    _textLabel.numberOfLines = 0;
    [self addSubview:_textLabel];
}

#pragma mark - Setters

- (void)setMessage:(NSString *)message {
    
    if (![_message isEqualToString:message]) {
        
        _message = message;
        
        self.textLabel.text = message;
        
        CGFloat width = [self.textLabel.text sizeWithAttributes:@{NSFontAttributeName : self.textLabel.font}].width;
        if (width > self.textLabel.bounds.size.width) {
            // Text label and base view needs to be resized
            [self.textLabel sizeToFit];
            
            CGFloat height = self.textLabel.frame.size.height;
            CGFloat frameHeight = (kQMVerticalSpace * 2) + height;
            
            self.frame = CGRectMake(self.frame.origin.x,
                                    self.frame.origin.y,
                                    self.frame.size.width,
                                    frameHeight);
            self.visualEffectView.frame = self.frame;
            self.bgColorView.frame = self.frame;
        }
    }
}

#pragma mark - Helpers

static inline UIColor *color(QMNotificationPanelType notificationPanelType) {
    
    switch (notificationPanelType) {
            
        case QMNotificationPanelTypeSuccess:
            return successColor();
            
        case QMNotificationPanelTypeWarning:
            return warningColor();
            
        case QMNotificationPanelTypeFailed:
            return failedColor();
            
        case QMNotificationPanelTypeLoading:
            return loadingColor();
    }
}

static inline UIImage *image(QMNotificationPanelType notificationPanelType) {
    
    switch (notificationPanelType) {
            
        case QMNotificationPanelTypeSuccess:
            return successImage();
            
        case QMNotificationPanelTypeWarning:
            return warningImage();
            
        case QMNotificationPanelTypeFailed:
            return failImage();
            
        case QMNotificationPanelTypeLoading:
            return nil;
    }
}

@end
