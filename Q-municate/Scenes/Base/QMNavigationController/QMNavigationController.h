//
//  QMNavigationController.h
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 6/16/17.
//  Copyright © 2017 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "QMNotificationPanelView.h"

extern NSString * const kQMNavigationBarHeightChangeNotification;

@interface QMNavigationController : UINavigationController

@property (nonatomic) CGFloat currentAdditionalNavigationBarHeight;

- (void)showNotificationWithType:(QMNotificationPanelType)notificationType message:(NSString *)message duration:(NSTimeInterval)duration;
- (void)dismissNotificationPanel;
- (void)shake;

@end
