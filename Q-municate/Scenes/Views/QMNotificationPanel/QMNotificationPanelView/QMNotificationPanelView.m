//
//  QMNotificationPanelView.m
//  Q-municate
//
//  Created by Injoit on 3/26/16.
//  Copyright © 2016 QuickBlox. All rights reserved.
//

#import "QMNotificationPanelView.h"
#import "QMNotificationPanelUtils.h"

static const CGFloat kQMVerticalSpace = 8.0f;
static const CGFloat kQMHorizontalSpace = 4.5f;
static const CGFloat kQMIconSize = 26.0f;

@interface QMNotificationPanelView ()

@property (strong, nonatomic) UILabel *textLabel;

@property (strong, nonatomic) UIActivityIndicatorView *activityIndicatorView;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIVisualEffectView *visualEffectView;
@property (strong, nonatomic) UIView *bgColorView;

@end

@implementation QMNotificationPanelView

//MARK: - Construction

- (instancetype)initWithFrame:(CGRect)frame
        notificationPanelType:(QMNotificationPanelType)notificationPanelType {
    
    self = [super initWithFrame:frame];
    if (self) {
        _notificationPanelType = notificationPanelType;
        [self configureBlurWithFrame:frame backgroundColor:color(notificationPanelType)];
        [self configureExtraIcons];
        [self updateExtraIconsStateWithNotificationPanelType:notificationPanelType];
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

- (void)configureExtraIcons {
    
    // init activity indicator
    _activityIndicatorView =
    [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(kQMVerticalSpace,
                                                              kQMHorizontalSpace,
                                                              kQMIconSize,
                                                              kQMIconSize)];
    _activityIndicatorView.backgroundColor = [UIColor clearColor];
    [_bgColorView addSubview:_activityIndicatorView];
    
    // init image view
    _imageView =
    [[UIImageView alloc] initWithFrame:CGRectMake(kQMVerticalSpace,
                                                  kQMHorizontalSpace,
                                                  kQMIconSize,
                                                  kQMIconSize)];
    
    _imageView.backgroundColor = [UIColor clearColor];
    [_bgColorView addSubview:_imageView];
}

- (void)configureTextLabelWithFrame:(CGRect)frame {
    // init text label
    CGFloat textLabelX = kQMVerticalSpace + kQMIconSize + kQMVerticalSpace;
    _textLabel =
    [[UILabel alloc] initWithFrame:CGRectMake(textLabelX,
                                              kQMHorizontalSpace,
                                              frame.size.width - textLabelX - kQMHorizontalSpace,
                                              26.0f)];
    _textLabel.userInteractionEnabled = YES;
    _textLabel.textColor = [UIColor whiteColor];
    _textLabel.numberOfLines = 0;
    [_bgColorView addSubview:_textLabel];
}

//MARK: - Setters

- (void)setNotificationPanelType:(QMNotificationPanelType)notificationPanelType {
    
    if (_notificationPanelType != notificationPanelType) {
        _notificationPanelType = notificationPanelType;
        _bgColorView.backgroundColor = color(notificationPanelType);
        [self updateExtraIconsStateWithNotificationPanelType:notificationPanelType];
    }
}

- (void)setMessage:(NSString *)message {
    
    if (![_message isEqualToString:message]) {
        
        _message = [message copy];
        
        self.textLabel.text = message;
        
        CGFloat width = [self.textLabel.text sizeWithAttributes:@{NSFontAttributeName : self.textLabel.font}].width;
        CGFloat labelWidth = CGRectGetWidth(self.textLabel.bounds);
        
        if (width > labelWidth) {
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

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    self.visualEffectView.frame = frame;
    self.bgColorView.frame = frame;
}

//MARK: - Helpers

- (void)updateExtraIconsStateWithNotificationPanelType:(QMNotificationPanelType)notificationPanelType {
    switch (notificationPanelType) {
        case QMNotificationPanelTypeSuccess:
        case QMNotificationPanelTypeWarning:
        case QMNotificationPanelTypeFailed:
            _imageView.image = image(notificationPanelType);
            _imageView.hidden = NO;
            [_activityIndicatorView stopAnimating];
            _activityIndicatorView.hidden = YES;
            break;
            
        case QMNotificationPanelTypeLoading:
            _activityIndicatorView.hidden = NO;
            [_activityIndicatorView startAnimating];
            _imageView.hidden = YES;
            break;
    }
}

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
