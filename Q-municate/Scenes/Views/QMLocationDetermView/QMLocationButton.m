//
//  QMLocationButton.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 7/5/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMLocationButton.h"

#import <QuartzCore/QuartzCore.h>

static UIImage *locationImage() {
    
    static UIImage *loc = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        loc = [UIImage imageNamed:@"qm-ic-location"];
    });
    
    return loc;
}

static UIColor *backgroundColor() {
    
    static UIColor *color = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        CGFloat value = 249.0f/255.0f;
        color = [UIColor colorWithRed:value green:value blue:value alpha:1.0f];
    });
    
    return color;
}

static UIColor *borderColor() {
    
    static UIColor *color = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        CGFloat value = 151.0f/255.0f;
        color = [UIColor colorWithRed:value green:value blue:value alpha:1.0f];
    });
    
    return color;
}

static const NSUInteger kQMViewCornerRadius = 4;
static const CGFloat kQMBorderWidth = 0.5f;

static const CGFloat kQMLocationImageSize = 18.0f;
static const CGFloat kQMLocationButtonXShift = 2.0f;

@interface QMLocationButton ()
{
    UIImageView *_locationImageView;
}

@property (strong, nonatomic) UIActivityIndicatorView *activityIndicatorView;

@end

@implementation QMLocationButton

#pragma mark - Construction

- (instancetype)init {
    
    self = [super init];
    if (self != nil) {
        
        [self commonInit];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self != nil) {
        
        [self commonInit];
    }
    
    return self;
}

- (void)commonInit {
    
    self.backgroundColor = backgroundColor();
    self.layer.cornerRadius = kQMViewCornerRadius;
    self.layer.masksToBounds = YES;
    self.layer.borderColor = borderColor().CGColor;
    self.layer.borderWidth = kQMBorderWidth;
    
    _locationImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,
                                                                       0,
                                                                       kQMLocationImageSize,
                                                                       kQMLocationImageSize)];
    _locationImageView.image = locationImage();
    _locationImageView.center = CGPointMake(CGRectGetWidth(self.frame) / 2.0f - kQMLocationButtonXShift,
                                            CGRectGetHeight(self.frame) / 2.0f);
    _locationImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    
    [self addSubview:_locationImageView];
}

#pragma mark - Getters

- (UIActivityIndicatorView *)activityIndicatorView {
    
    if (_activityIndicatorView == nil) {
        
        _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _activityIndicatorView.center = CGPointMake(CGRectGetWidth(self.frame) / 2.0f,
                                                    CGRectGetHeight(self.frame) / 2.0f);
        _activityIndicatorView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        
        [self addSubview:_activityIndicatorView];
    }
    
    return _activityIndicatorView;
}

#pragma mark - Methods

- (void)setLoadingState:(BOOL)loadingState {
    
    if (_loadingState != loadingState) {
        
        _loadingState = loadingState;
        
        self.userInteractionEnabled = !loadingState;
        _locationImageView.hidden = loadingState;
        self.activityIndicatorView.hidden = !loadingState;
        
        if (loadingState) {
            
            [self.activityIndicatorView startAnimating];
        }
        else {
            
            [self.activityIndicatorView stopAnimating];
        }
    }
}

@end
