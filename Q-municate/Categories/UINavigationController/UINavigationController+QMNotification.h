//
//  UINavigationController+QMNotification.h
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 5/19/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QMNotificationPanel.h"

@interface UINavigationController (QMNotification)

- (void)showNotificationWithType:(QMNotificationPanelType)notificationType message:(NSString *)message duration:(NSTimeInterval)duration;

- (void)dismissNotificationPanel;

@end
