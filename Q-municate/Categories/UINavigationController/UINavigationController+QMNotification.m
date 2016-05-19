//
//  UINavigationController+QMNotification.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 5/19/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "UINavigationController+QMNotification.h"
#import <objc/runtime.h>

@interface UINavigationController (QMNotification_Private)

@property (strong, nonatomic) QMNotificationPanel *notificationPanel;

@end

@implementation UINavigationController (QMNotification_Private)

- (void)setNotificationPanel:(QMNotificationPanel *)notificationPanel {
    
    objc_setAssociatedObject(self, @selector(notificationPanel), notificationPanel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (QMNotificationPanel *)notificationPanel {
    
    return objc_getAssociatedObject(self, @selector(notificationPanel));
}

@end

@implementation UINavigationController (QMNotification)

- (void)showNotificationWithType:(QMNotificationPanelType)notificationType message:(NSString *)message duration:(NSTimeInterval)duration {
    
    if (self.notificationPanel == nil) {
        
        self.notificationPanel = [[QMNotificationPanel alloc] init];
    }
    
    BOOL hasActiveNotification = self.notificationPanel.hasActiveNotification;
    BOOL animated = !hasActiveNotification;
    
    if (hasActiveNotification) {
        
        [self.notificationPanel dismissNotificationAnimated:animated];
    }
    
    self.notificationPanel.timeUntilDismiss = duration;
    
    [self.notificationPanel showNotificationWithType:notificationType byInsertingInNavigationBar:self.navigationBar message:message animated:animated];
}

- (void)dismissNotificationPanel {
    
    [self.notificationPanel dismissNotificationAnimated:YES];
}

@end
