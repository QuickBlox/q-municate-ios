//
//  QMNotificationView.h
//  Q-municate
//
//  Created by Andrey Ivanov on 19.03.15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QMNotificationView : UIView

@property (readonly, nonatomic, getter = isVisible) BOOL visible;

+ (QMNotificationView *)showInViewController:(UIViewController *)viewController;

- (void)setVisible:(BOOL)visible
          animated:(BOOL)animated
        completion:(dispatch_block_t)completion;

- (void)dismissAnimated:(BOOL)animated;

@end
