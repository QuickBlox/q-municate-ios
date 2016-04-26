//
//  QMNotificationPanel.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 3/26/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMNotificationPanel.h"

static const CGFloat kQMDefaultNotificationViewHeight = 36.0f;
static const CGFloat kQMFadeAnimationHeightShift = 10.0f;

@interface QMNotificationPanel ()

@property (strong, nonatomic) UIView *view;
@property (strong, nonatomic) UITapGestureRecognizer *tapGesture;
@property (assign, nonatomic) CGFloat verticalSpace;

@property (strong, nonatomic) NSTimer *timer;

@end

@implementation QMNotificationPanel

#pragma mark - Construction

- (instancetype)init {
    
    self = [super init];
    if (self) {
        
        _enableTapDismiss = YES;
        _timeUntilDismiss = kQMDefaultNotificationDismissTime;
    }
    
    return self;
}

#pragma mark - Methods

- (void)showNotificationWithView:(UIView *)view inView:(UIView *)innerView animated:(BOOL)animated {
    
    [self resetAnimated:NO];
    
    CGFloat width = innerView.frame.size.width;
    CGFloat height = view.frame.size.height;
    CGFloat top = self.verticalSpace;
    
    self.view = [[UIView alloc] init];
    self.view.tag = kQMNotificationPanelTag;
    
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didRecognizedTap:)];
    [self.view addGestureRecognizer:self.tapGesture];
    
    self.view.alpha = 0;
    self.view.frame = CGRectMake(0,
                                 top,
                                 width,
                                 height);
    self.view.backgroundColor = [UIColor clearColor];
    [self.view addSubview:view];
    [self.view bringSubviewToFront:view];
    
    view.autoresizingMask = self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    @weakify(self);
    
    if (animated) {
        
        [innerView addSubview:self.view];
    }
    else {
        
        [UIView performWithoutAnimation:^{
            
            @strongify(self);
            [innerView addSubview:self.view];
        }];
    }
    
    [UIView animateWithDuration:kQMBaseAnimationDuration animations:^{
        
        @strongify(self);
        self.view.alpha = 1.0f;
        
    } completion:^(BOOL finished) {
        
        @strongify(self);
        if (self.timeUntilDismiss > 0 && finished) {
            
            // fade animation
            self.timer = [NSTimer scheduledTimerWithTimeInterval:self.timeUntilDismiss target:self selector:@selector(animateFade) userInfo:nil repeats:NO];
        }
    }];
}

- (void)showNotificationWithType:(QMNotificationPanelType)notificationType inView:(UIView *)innerView message:(NSString *)message animated:(BOOL)animated {
    
    self.verticalSpace = 0;
    QMNotificationPanelView *notificationPanelView = [self notificationPanelViewWithType:notificationType message:message];
    
    [self showNotificationWithView:notificationPanelView inView:innerView animated:animated];
}

- (void)showNotificationWithType:(QMNotificationPanelType)notificationType belowNavigation:(UINavigationController *)navigationController message:(NSString *)message animated:(BOOL)animated {
    
    self.verticalSpace = CGRectGetHeight(navigationController.navigationBar.frame);
    
    QMNotificationPanelView *notificationPanelView = [self notificationPanelViewWithType:notificationType message:message];
    
    [self showNotificationWithView:notificationPanelView inView:navigationController.view animated:animated];
}

- (void)showNotificationWithType:(QMNotificationPanelType)notificationType byInsertingInNavigationBar:(UINavigationBar *)navigationBar message:(NSString *)message animated:(BOOL)animated {
    
    self.verticalSpace = CGRectGetHeight(navigationBar.frame);
    
    QMNotificationPanelView *notificationPanelView = [self notificationPanelViewWithType:notificationType message:message];
    
    [self showNotificationWithView:notificationPanelView inView:navigationBar animated:animated];
}

- (void)dismissNotificationAnimated:(BOOL)animated {
    
    if ([self resetAnimated:animated] && [self.delegate respondsToSelector:@selector(notificationPanelDidDismiss:)]) {
        
        [self.delegate notificationPanelDidDismiss:self];
    }
}

#pragma mark - Getters

- (BOOL)hasActiveNotification {
    
    return _view != nil;
}

#pragma mark - Actions

- (void)didRecognizedTap:(UITapGestureRecognizer *)recognizer {
    
    if (self.isTapDismissEnabled) {
        
        [self dismissNotificationAnimated:YES];
    }
    
    if ([self.delegate respondsToSelector:@selector(notificationPanel:didRecognizedTap:)]) {
        
        [self.delegate notificationPanel:self didRecognizedTap:recognizer];
    }
}

#pragma mark - Helpers

- (QMNotificationPanelView *)notificationPanelViewWithType:(QMNotificationPanelType)type message:(NSString *)message {
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    
    QMNotificationPanelView *notificationPanelView = [[QMNotificationPanelView alloc] initWithFrame:CGRectMake(0,
                                                                                                               0,
                                                                                                               width,
                                                                                                               kQMDefaultNotificationViewHeight)
                                                                              notificationPanelType:type];
    notificationPanelView.message = message;
    
    return notificationPanelView;
}

- (void)animateFade {
    
    if (self.view == nil) {
        
        return;
    }
    
    CGRect frame = self.view.frame;
    frame.size.height -= kQMFadeAnimationHeightShift;
    
    @weakify(self);
    [UIView animateWithDuration:kQMBaseAnimationDuration animations:^{
        
        @strongify(self);
        self.view.alpha = 0;
        self.view.frame = frame;
        
    } completion:^(BOOL __unused finished) {
        
        @strongify(self);
        [self dismissNotificationAnimated:YES];
    }];
}

- (BOOL)resetAnimated:(BOOL)animated {
    
    if (self.view != nil) {
        
        [self.timer invalidate];
        self.timer = nil;
        [self.view removeGestureRecognizer:self.tapGesture];
        
        if (animated) {
            
            [self.view removeFromSuperview];
        }
        else {
            
            @weakify(self);
            [UIView performWithoutAnimation:^{
                
                @strongify(self);
                [self.view removeFromSuperview];
            }];
        }
        
        self.view = nil;
        
        return YES;
    }
    
    return NO;
}

@end
