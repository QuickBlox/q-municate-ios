//
//  QMNavigationBar.h
//  Q-municate
//
//  Created by Injoit on 4/1/16.
//  Copyright © 2016 QuickBlox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QMNotificationPanelView.h"

@interface QMNavigationBar : UINavigationBar

@property (assign, nonatomic) QMNotificationPanelType notificationPanelType;
@property (copy, nonatomic) NSString *message;
@property (assign, nonatomic) NSUInteger restrictedLargeTitles;
@property (assign, nonatomic) CGFloat additionalBarShift;

- (void)showNotificationPanelView:(BOOL)show animation:(dispatch_block_t)animation;
- (void)shake;

@end
