//
//  QMNavigationController.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 6/16/17.
//  Copyright © 2017 Quickblox. All rights reserved.
//

#import "QMNavigationController.h"
#import "QMNavigationBar.h"

#import "QMViewController.h"
#import "QMTableViewController.h"
#import "QMChatVC.h"

NSString * const kQMNavigationBarHeightChangeNotification = @"kQMNavigationBarHeightChangeNotification";

static const CGFloat kQMNotificationPanelViewHeight = 36.0f;

@interface QMNavigationController () {
    NSTimer *_dismissTimer;
    BOOL _notificationShown;
}

@property (nonatomic, readwrite) BOOL notificationShown;

@end

@implementation QMNavigationController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    
    if (iosMajorVersion() >= 11) {
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        self.navigationBar.prefersLargeTitles = YES;
#pragma clang diagnostic pop
    }
}

- (void)showNotificationWithType:(QMNotificationPanelType)notificationType message:(NSString *)message duration:(NSTimeInterval)duration {
    
    if ([self.navigationBar isKindOfClass:[QMNavigationBar class]]) {
        
        BOOL notify = YES;
        if (_notificationShown) {
            [_dismissTimer invalidate];
            _dismissTimer = nil;
            notify = NO;
        }
        
        QMNavigationBar *navigationBar = (QMNavigationBar *)self.navigationBar;
        navigationBar.notificationPanelType = notificationType;
        navigationBar.message = message;
        
        _currentAdditionalNavigationBarHeight = kQMNotificationPanelViewHeight;
        
        _notificationShown = YES;
        
        if (duration > 0) {
            _dismissTimer = [NSTimer scheduledTimerWithTimeInterval:duration target:self selector:@selector(dismissNotificationPanel) userInfo:nil repeats:NO];
        }
        
        __weak __typeof(self)weakSelf = self;
        [navigationBar showNotificationPanelView:YES animation:^{
            if (notify) {
                [weakSelf updateNotificationOnControllers];
            }
        }];
    }
}

- (void)dismissNotificationPanel {
    
    if (_notificationShown) {
        _currentAdditionalNavigationBarHeight = 0;
        QMNavigationBar *navigationBar = (QMNavigationBar *)self.navigationBar;
        __weak __typeof(self)weakSelf = self;
        [navigationBar showNotificationPanelView:NO animation:^{
            [weakSelf updateNotificationOnControllers];
        }];
        [_dismissTimer invalidate];
        _dismissTimer = nil;
        _notificationShown = NO;
    }
}

- (void)shake {
    if ([self.navigationBar isKindOfClass:[QMNavigationBar class]]) {
        [(QMNavigationBar *)self.navigationBar shake];
    }
}

- (void)setCurrentAdditionalNavigationBarHeight:(CGFloat)currentAdditionalNavigationBarHeight {
    _currentAdditionalNavigationBarHeight = currentAdditionalNavigationBarHeight;
    [self updateNotificationOnControllers];
}

- (void)updateNotificationOnControllers {
    [[NSNotificationCenter defaultCenter]
     postNotificationName:kQMNavigationBarHeightChangeNotification
     object:nil];
}

@end
