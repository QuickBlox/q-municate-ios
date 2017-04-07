//
//  QMLocalVideoView.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 5/12/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMLocalVideoView.h"

static UIColor *backgroundColor() {
    
    static UIColor *color = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        color = [UIColor colorWithRed:74.0f/255.0f green:74.0f/255.0f blue:74.0f/255.0f alpha:1.0f];
    });
    
    return color;
}

static UIImage *camoffImage() {
    
    static UIImage *image = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        image = [UIImage imageNamed:@"qm-ic-camoff"];
    });
    
    return image;
}

static const CGFloat preferredPointX = 16.0f;
static const CGFloat preferredPointY = 32.0f;
static const CGFloat preferredSizeA = 75.0f;
static const CGFloat preferredSizeB = 100.0f;

@interface QMLocalVideoView ()

@property (weak, nonatomic) AVCaptureVideoPreviewLayer *previewLayer;

@property (strong, nonatomic) UIView *blurView;
@property (strong, nonatomic) UIImageView *camoffImageView;

@end

@implementation QMLocalVideoView

//MARK: - Static

+ (CGRect)preferredFrameForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
    switch (interfaceOrientation) {
            
        case UIInterfaceOrientationUnknown:
            NSAssert(nil, @"Interface orientation must be specified. Check that interface orientation notifications are enabled.");
            return CGRectNull;
            
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
            return CGRectMake(preferredPointX,
                              preferredPointY,
                              preferredSizeA,
                              preferredSizeB);
            
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
            return CGRectMake(preferredPointX,
                              preferredPointY,
                              preferredSizeB,
                              preferredSizeA);
    }
}

//MARK: - Construction

- (instancetype)initWithPreviewLayer:(AVCaptureVideoPreviewLayer *)previewLayer {
    
    self = [super init];
    if (self) {
        
        _previewLayer = previewLayer;
        
        [self configureImageView];
        
        _previewLayerVisible = YES;
        [self.layer insertSublayer:_previewLayer atIndex:0];
        
        _blurEffectEnabled = YES;
        [self configureBlurView];
        
        self.backgroundColor = backgroundColor();
    }
    
    return self;
}

//MARK: - Configurations

- (void)configureImageView {
    
    _camoffImageView = [[UIImageView alloc] initWithImage:camoffImage()];
    CGRect frame = _camoffImageView.frame;
    frame.size = CGSizeMake(30.0f, 24.0f);
    frame.origin = self.center;
    _camoffImageView.frame = frame;
    _camoffImageView.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin);
    _camoffImageView.hidden = YES;
    
    [self addSubview:_camoffImageView];
}

- (void)configureBlurView {
    
    _blurView = [[UIView alloc] init];
    _blurView.backgroundColor = [UIColor blackColor];
    _blurView.alpha = 0.6f;
    
    [self addSubview:_blurView];
}

//MARK: - Setters

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    self.previewLayer.frame = self.bounds;
    self.blurView.frame = self.bounds;
}

- (void)setBlurEffectEnabled:(BOOL)blurEffectEnabled {
    
    if (_blurEffectEnabled != blurEffectEnabled) {
        
        _blurEffectEnabled = blurEffectEnabled;
        
        if (blurEffectEnabled) {
            
            [self configureBlurView];
        }
        else {
            
            [self.blurView removeFromSuperview];
            self.blurView = nil;
        }
    }
}

- (void)setPreviewLayerVisible:(BOOL)previewLayerVisible {
    
    if (_previewLayerVisible != previewLayerVisible) {
        
        _previewLayerVisible = previewLayerVisible;
        
        if (previewLayerVisible) {
            
            self.camoffImageView.hidden = YES;
            [self.layer insertSublayer:self.previewLayer atIndex:0];
        }
        else {
            
            [self.previewLayer removeFromSuperlayer];
            self.camoffImageView.hidden = NO;
        }
    }
}

@end
