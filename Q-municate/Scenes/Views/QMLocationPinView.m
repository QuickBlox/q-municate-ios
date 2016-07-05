//
//  QMLocationPinView.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 7/5/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMLocationPinView.h"

const CGFloat QMLocationPinViewOriginPinCenter = 7.0f;

static const CGFloat kQMLocationPinDamping = 3.5f;
static const CGFloat kQMLocationPinRaisedOrigin = -40.0f;
static const CGPoint kQMLocationPinShadowPinnedOrigin = { 3.0f, 8.0f };
static const CGPoint kQMLocationPinShadowRaisedOrigin = { 47.0f, -72.0f };
static const CGSize kQMLocationPinSize = { 14.0f, 36.0f };

@interface QMLocationPinView ()
{
    UIImageView *_pinView;
    UIImageView *_pinPointView;
    UIImageView *_shadowView;
}

@end

@implementation QMLocationPinView

#pragma mark - Construction

- (instancetype)init {
    
    self = [super initWithFrame:CGRectMake(0, 0, 27.0f, 37.0f)];
    
    if (self != nil) {
        
        self.userInteractionEnabled = NO;;
        
        _shadowView = [[UIImageView alloc] initWithFrame:CGRectMake(kQMLocationPinShadowPinnedOrigin.x,
                                                                    kQMLocationPinShadowPinnedOrigin.y,
                                                                    26.0f,
                                                                    32.0f)];
        _shadowView.alpha = 0.9f;
        _shadowView.image = [UIImage imageNamed:@"qm-sh-location_pin"];
        [self addSubview:_shadowView];
        
        _pinPointView = [[UIImageView alloc] initWithFrame:CGRectMake(5.0f, 35.0f, 4.0f, 2.0f)];
        _pinPointView.image = [UIImage imageNamed:@"qm-pnt-location_pin"];
        [self addSubview:_pinPointView];
        
        _pinView = [[UIImageView alloc] initWithFrame:CGRectMake(0,
                                                                 0,
                                                                 kQMLocationPinSize.width,
                                                                 kQMLocationPinSize.height)];
        _pinView.image = [UIImage imageNamed:@"qm-ic-location_pin"];
        [self addSubview:_pinView];
    }
    
    return self;
}

#pragma mark - Setters

- (void)setPinRaised:(BOOL)pinRaised {
    
    [self setPinRaised:pinRaised animated:NO];
}

- (void)setPinRaised:(BOOL)pinRaised animated:(BOOL)animated {
    
    if (_pinRaised != pinRaised) {
        
        _pinRaised = pinRaised;
        
        [_pinView.layer removeAllAnimations];
        [_shadowView.layer removeAllAnimations];
        
        if (animated) {
            
            if (pinRaised) {
                
                [UIView animateWithDuration:kQMBaseAnimationDuration delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                    
                    self->_pinView.frame = CGRectMake(CGRectGetMinX(self->_pinView.frame),
                                                      kQMLocationPinRaisedOrigin,
                                                      kQMLocationPinSize.width,
                                                      kQMLocationPinSize.height);
                    
                    self->_shadowView.frame = CGRectMake(kQMLocationPinShadowRaisedOrigin.x,
                                                         kQMLocationPinShadowRaisedOrigin.y,
                                                         CGRectGetWidth(self->_shadowView.frame),
                                                         CGRectGetHeight(self->_shadowView.frame));
                } completion:nil];
            }
            else {
                
                [UIView animateWithDuration:kQMBaseAnimationDuration delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                    
                    self->_pinView.frame = CGRectMake(CGRectGetMinX(self->_pinView.frame),
                                                      0,
                                                      kQMLocationPinSize.width,
                                                      kQMLocationPinSize.height);
                    
                    self->_shadowView.frame = CGRectMake(kQMLocationPinShadowPinnedOrigin.x,
                                                         kQMLocationPinShadowPinnedOrigin.y,
                                                         CGRectGetWidth(self->_shadowView.frame),
                                                         CGRectGetHeight(self->_shadowView.frame));
                    
                } completion:^(BOOL finished) {
                    
                    if (finished) {
                        
                        [UIView animateWithDuration:kQMSlashAnimationDuration delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                            
                            self->_pinView.frame = CGRectMake(CGRectGetMinX(self->_pinView.frame),
                                                              kQMLocationPinDamping,
                                                              kQMLocationPinSize.width,
                                                              kQMLocationPinSize.height - kQMLocationPinDamping);
                            
                        } completion:^(BOOL finished_t) {
                            
                            if (finished_t) {
                                
                                [UIView animateWithDuration:kQMSlashAnimationDuration delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                                    
                                    self->_pinView.frame = CGRectMake(CGRectGetMinX(self->_pinView.frame),
                                                                      0,
                                                                      kQMLocationPinSize.width,
                                                                      kQMLocationPinSize.height);
                                } completion:nil];
                            }
                        }];
                    }
                }];
            }
        }
        else {
            
            _pinView.frame = CGRectMake(CGRectGetMinX(self->_pinView.frame),
                                        pinRaised ? kQMLocationPinRaisedOrigin : 0,
                                        kQMLocationPinSize.width,
                                        kQMLocationPinSize.height);
            
            CGPoint shadowOrigin = pinRaised ? kQMLocationPinShadowRaisedOrigin : kQMLocationPinShadowPinnedOrigin;
            _shadowView.frame = CGRectMake(shadowOrigin.x,
                                           shadowOrigin.y,
                                           CGRectGetWidth(self->_shadowView.frame),
                                           CGRectGetHeight(self->_shadowView.frame));
        }
    }
}

@end
