//
//  QMNavigationBar.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 4/1/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMNavigationBar.h"
#import "QMNotificationPanel.h"
#import <QMImageView.h>

@interface QMNavigationBar ()

@property (weak, nonatomic) UIView *notificationView;

@end

@implementation QMNavigationBar

- (void)layoutSubviews {
    [super layoutSubviews];
    
    NSArray *classNamesToReposition = @[@"UINavigationButton", @"_UINavigationBarBackIndicatorView", @"UINavigationItemButtonView", NSStringFromClass([QMImageView class])];
    
    for (UIView *view in self.subviews) {
        
        if ([classNamesToReposition containsObject:NSStringFromClass([view class])]) {
            
            CGRect frame = [view frame];
            frame.origin.y -= CGRectGetHeight(self.notificationView.frame);
            if (frame.origin.y < 0) {
                
                continue;
            }
            
            [view setFrame:frame];
            
#warning Back button title still not in correct Y dimension
            if ([view class] == NSClassFromString(@"UINavigationItemButtonView")) {
                
                [view.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger __unused idx, BOOL * _Nonnull __unused stop) {
                    
                    CGRect newFrame = [obj frame];
                    newFrame.origin.y = frame.origin.y;
                    
                    [obj setFrame:newFrame];
                }];
            }
        }
    }
}

- (void)didAddSubview:(UIView *)subview {
    [super didAddSubview:subview];
    
    if (subview.tag == kQMNotificationPanelTag) {
        self.notificationView = subview;
        
        CGRect frame = subview.frame;
        frame.origin.y += frame.size.height;
        subview.frame = frame;
        
        [self updateAppearance];
    }
}

- (void)willRemoveSubview:(UIView *)subview {
    [super willRemoveSubview:subview];
    
    if (subview.tag == kQMNotificationPanelTag) {
        self.notificationView = nil;
        
        [self updateAppearance];
    }
}

- (void)updateAppearance {
    
    [self setTitleVerticalPositionAdjustment:-CGRectGetHeight(self.notificationView.frame) forBarMetrics:UIBarMetricsDefault];
    
    [UIView animateWithDuration:kQMBaseAnimationDuration animations:^{
        
        [self sizeToFit];
        [self.window.rootViewController.viewIfLoaded layoutSubviews];
    }];
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGSize sizeThatFits = [super sizeThatFits:size];
    
    if (self.notificationView) {
        
        sizeThatFits.height += CGRectGetHeight(self.notificationView.frame);
    }
    
    return sizeThatFits;
}

@end
