//
//  QMNavigationBar.h
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 4/1/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QMNotificationPanelView.h"

@interface QMNavigationBar : UINavigationBar

@property (assign, nonatomic) QMNotificationPanelType notificationPanelType;
@property (copy, nonatomic) NSString *message;

- (void)showNotificationPanelView:(BOOL)show animation:(void (^)())animation;
- (void)shake;

@end
