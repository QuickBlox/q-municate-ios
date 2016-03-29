//
//  QMNotificationPanel.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 3/26/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMNotificationPanel.h"
#import "QMNotificationPanelView.h"

static const NSUInteger kQMAnimationsCount = 4;

typedef void(^animationBlock)(BOOL);

@interface QMNotificationPanel ()

@property (strong, nonatomic) UIView *view;
@property (strong, nonatomic) UIView *innerView;
@property (strong, nonatomic) UITapGestureRecognizer *tapGesture;
@property (assign, nonatomic) CGFloat verticalSpace;

@property (strong, nonatomic) NSMutableArray *animationBlocks;
@property (strong, nonatomic) NSTimer *timer;

@end

@implementation QMNotificationPanel

#pragma mark - Construction

- (instancetype)init {
    
    self = [super init];
    if (self) {
        
        _enableTapDismiss = YES;
        _timeUntilDismiss = 2.0f;
    }
    
    return self;
}

#pragma mark - Methods

- (void)showNotificationWithView:(UIView *)view inView:(UIView *)innerView {
    
    [self reset];
    
    CGFloat width = innerView.frame.size.width;
    CGFloat height = view.frame.size.height;
    CGFloat top = (-height / 2.0f) + self.verticalSpace;
    
    self.view = [[UIView alloc] init];
    
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didRecognizedTap:)];
    [self.view addGestureRecognizer:self.tapGesture];
    
    self.view.alpha = 0.0f;
    self.view.frame = CGRectMake(0.0f,
                                 top,
                                 width,
                                 height);
    self.view.backgroundColor = [UIColor clearColor];
    [self.view addSubview:view];
    [self.view bringSubviewToFront:view];
    
    [innerView addSubview:self.view];
    
    // Perform animation chain
    self.animationBlocks = [NSMutableArray arrayWithCapacity:kQMAnimationsCount];
    
    @weakify(self);
    
    animationBlock (^performNextAnimation)() = ^{
        
        @strongify(self);
        if (self.animationBlocks.count > 0) {
            
            animationBlock block = (animationBlock)self.animationBlocks.firstObject;
            [self.animationBlocks removeObjectAtIndex:0];
            
            return block;
        }
        else {
            
            return ^(BOOL __unused finished) {
                
                self.animationBlocks = nil;
            };
        }
    };
    
    [self.animationBlocks addObject:^(BOOL __unused finished){
        
        @strongify(self);
        [UIView animateWithDuration:0.2f animations:^{
            
            self.view.alpha = 1.0f;
            self.view.frame = CGRectMake(0.0f,
                                         self.verticalSpace,
                                         width,
                                         height + 5);
            
        } completion:performNextAnimation()];
    }];
    
    [self.animationBlocks addObject:^(BOOL __unused finished){
        
        @strongify(self);
        if (self.view == nil) {
            
            self.animationBlocks = nil;
            return;
        }
        
        [UIView animateWithDuration:0.2f animations:^{
            
            self.view.frame = CGRectMake(0.0f,
                                         self.verticalSpace,
                                         width,
                                         height);
            
        } completion:performNextAnimation()];
    }];
    
    [self.animationBlocks addObject:^(BOOL finished){
        
        @strongify(self);
        if (self.timeUntilDismiss > 0 && finished) {
            
            // fade animation
            self.timer = [NSTimer scheduledTimerWithTimeInterval:self.timeUntilDismiss target:self selector:@selector(animateFade) userInfo:nil repeats:NO];
        }
    }];
    
    // execute the first block in the queue
    performNextAnimation()(YES);
}

- (void)showNotificationWithType:(QMNotificationPanelType)notificationType inView:(UIView *)innerView message:(NSString *)message {
    
    self.verticalSpace = 0.0f;
    QMNotificationPanelView *notificationPanelView = [self notificationPanelViewWithType:notificationType message:message];
    
    [self showNotificationWithView:notificationPanelView inView:innerView];
}

- (void)showNotificationWithType:(QMNotificationPanelType)notificationType belowNavigation:(UINavigationController *)navigationController message:(NSString *)message {
    
    self.verticalSpace = navigationController.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height;
    QMNotificationPanelView *notificationPanelView = [self notificationPanelViewWithType:notificationType message:message];
    
    [self showNotificationWithView:notificationPanelView inView:navigationController.view];
}

- (void)dismissNotification {
    
    if ([self reset]) {
        
        [self.delegate notificationPanelDidDismiss:self];
    }
}

#pragma mark - Actions

- (void)didRecognizedTap:(UITapGestureRecognizer *)recognizer {
    
    if (self.isTapDismissEnabled) {
        
        [self dismissNotification];
    }
    
    [self.delegate notificationPanel:self didRecognizedTap:recognizer];
}

#pragma mark - Helpers

- (QMNotificationPanelView *)notificationPanelViewWithType:(QMNotificationPanelType)type message:(NSString *)message {
    
    CGFloat height = 44.0f;
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    
    QMNotificationPanelView *notificationPanelView = [[QMNotificationPanelView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, width, height) notificationPanelType:type];
    notificationPanelView.message = message;
    
    return notificationPanelView;
}

- (void)animateFade {
    
    if (self.view == nil) {
        
        return;
    }
    
    CGRect frame = self.view.frame;
    frame.size.height -= 10;
    
    @weakify(self);
    [UIView animateWithDuration:0.2f animations:^{
        
        @strongify(self);
        self.view.alpha = 0.0f;
        self.view.frame = frame;
        
    } completion:^(BOOL __unused finished) {
        
        @strongify(self);
        [self dismissNotification];
    }];
}

- (BOOL)reset {
    
    if (self.view != nil) {
        
        [self.timer invalidate];
        self.timer = nil;
        self.animationBlocks = nil;
        [self.view removeGestureRecognizer:self.tapGesture];
        [self.view removeFromSuperview];
        self.view = nil;
        
        return YES;
    }
    
    return NO;
}

@end
