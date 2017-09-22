//
//  QMNavigationBar.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 4/1/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMNavigationBar.h"

@interface QMNavigationBar () {
    BOOL _showNotification;
}

@property (strong, nonatomic) UIView *notificationPanelContainer;
@property (strong, nonatomic) QMNotificationPanelView *notificationPanelView;

@end

@implementation QMNavigationBar

- (void)setCenter:(CGPoint)center {
    [super setCenter:center];
    
    _notificationPanelContainer.alpha = center.y < 0.0f ? 0.0f : 1.0f;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    _notificationPanelContainer.alpha = frame.origin.y < 0.0f ? 0.0f : 1.0f;
    if (!_restrictedLargeTitles
        && iosMajorVersion() > 10) {
        _notificationPanelContainer.frame = CGRectMake(0.0f, frame.size.height + _additionalBarShift, frame.size.width, 37.0f);
    }
    else {
        _notificationPanelContainer.frame = CGRectMake(0.0f, frame.size.height, frame.size.width, 37.0f);
    }
}

// MARK: -

- (CGRect)notificationPanelFrameForContainerSize:(CGSize)containerSize {
    return CGRectMake(0, 0, containerSize.width, containerSize.height);
}

- (void)showNotificationPanelView:(BOOL)show animation:(void (^)())animation {
    _showNotification = show;
    if (show) {
        if (_notificationPanelContainer == nil) {
            _notificationPanelContainer = [[UIView alloc] init];
            _notificationPanelContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            _notificationPanelContainer.clipsToBounds = true;
            _notificationPanelContainer.frame = CGRectMake(0.0f, self.frame.size.height, self.frame.size.width, 37.0f);
            
            _notificationPanelView = [[QMNotificationPanelView alloc] initWithFrame:CGRectOffset(_notificationPanelContainer.bounds, 0.0f, -_notificationPanelContainer.frame.size.height) notificationPanelType:_notificationPanelType];
            _notificationPanelView.message = _message;
            _notificationPanelView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            [_notificationPanelContainer addSubview:_notificationPanelView];
            [self addSubview:_notificationPanelContainer];
        }
        _notificationPanelContainer.userInteractionEnabled = YES;
        
        __weak __typeof(self)weakSelf = self;
        [UIView animateWithDuration:0.3f delay:0.0f options:7 << 16 animations:^{
            weakSelf.notificationPanelView.frame = [weakSelf notificationPanelFrameForContainerSize:weakSelf.notificationPanelContainer.bounds.size];
            
            if (animation) {
                animation();
            }
        } completion:nil];
    }
    else if (_notificationPanelView != nil) {
        _notificationPanelContainer.userInteractionEnabled = NO;
        __weak __typeof(self)weakSelf = self;
        [UIView animateWithDuration:0.3f delay:0.0f options:7 << 16 animations:^
         {
             weakSelf.notificationPanelView.frame = CGRectOffset(weakSelf.notificationPanelContainer.bounds, 0.0f, -weakSelf.notificationPanelContainer.frame.size.height);
             if (animation) {
                 animation();
             }
         } completion:nil];
    }
}

- (void)shake {
    if (_showNotification) {
        CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.x"];
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        animation.duration = 0.8f;
        animation.values = @[@(-20), @(20), @(-20), @(20), @(-10), @(10), @(-5), @(5), @(0)];
        [self.notificationPanelContainer.layer addAnimation:animation forKey:@"shake"];
    }
}

- (void)setNotificationPanelType:(QMNotificationPanelType)notificationPanelType {
    if (_notificationPanelType != notificationPanelType) {
        _notificationPanelType = notificationPanelType;
        
        if (_notificationPanelView != nil) {
            _notificationPanelView.notificationPanelType = notificationPanelType;
        }
    }
}

- (void)setMessage:(NSString *)message {
    if (![_message isEqualToString:message]) {
        _message = [message copy];
        
        if (_notificationPanelView != nil) {
            _notificationPanelView.message = message;
        }
    }
}

/**
 Commented code down below allows custom notification view to receive touches.
 Uncomment it if you have implemented gestures there and they are not working.
 */
//- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
//    UIView *result = [_notificationPanelContainer hitTest:CGPointMake(point.x - _notificationPanelContainer.frame.origin.x, point.y - _notificationPanelContainer.frame.origin.y) withEvent:event];
//    if (result != nil) {
//        return result;
//    }
//    return [super hitTest:point withEvent:event];
//}

@end
