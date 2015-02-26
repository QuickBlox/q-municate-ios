//
//  REAlertView.h
//  Q-municate
//
//  Created by Andrey Ivanov on 22.10.12.
//  Copyright (c) 2014 QuickBlox. All rights reserved.
//

#import <UIKit/UIKit.h>

@class REAlertView;

typedef void(^REAlertButtonAction)();
typedef void(^REAlertConfiguration)(REAlertView *alertView);

@interface REAlertView : UIAlertView

- (void)dissmis;
- (void)addButtonWithTitle:(NSString *)title andActionBlock:(REAlertButtonAction)block;
+ (void)presentAlertViewWithConfiguration:(REAlertConfiguration)configuration;

@end