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
    
    NSArray *classNamesToReposition = @[@"_UINavigationBarBackground"];
    
    for (UIView *view in [self subviews]) {
        
        if ([classNamesToReposition containsObject:NSStringFromClass([view class])]) {
            
            CGRect bounds = [self bounds];
            CGRect frame = [view frame];
            
            CGFloat statusBarHeight = CGRectGetHeight([UIApplication sharedApplication].statusBarFrame);
            frame.origin.y = bounds.origin.y + CGRectGetHeight(self.notificationView.frame) - statusBarHeight;
            frame.size.height = bounds.size.height + statusBarHeight;
            
            [view setFrame:frame];
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
        
        [self sizeToFit];
        [self setTransform:CGAffineTransformMakeTranslation(0, -(CGRectGetHeight(self.notificationView.frame)))];
        
        [self.window.rootViewController.view layoutIfNeeded];
    }
}

- (void)willRemoveSubview:(UIView *)subview {
    [super willRemoveSubview:subview];
    
    if (subview.tag == kQMNotificationPanelTag) {
        self.notificationView = nil;
        
        [self setTransform:CGAffineTransformMakeTranslation(0, -(CGRectGetHeight(self.notificationView.frame)))];
        [self sizeToFit];
        
        [self.window.rootViewController.view layoutIfNeeded];
    }
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGSize sizeThatFits = [super sizeThatFits:size];
    
    if (self.notificationView) {
        
        sizeThatFits.height += CGRectGetHeight(self.notificationView.frame);
    }
    
    return sizeThatFits;
}

@end
