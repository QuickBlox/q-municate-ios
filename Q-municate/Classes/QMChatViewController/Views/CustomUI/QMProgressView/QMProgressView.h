//
//  QMProgressView.h
//  Pods
//
//  Created by Injoit on 2/20/17.
//  Copyright © 2017 QuickBlox. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QMProgressView : UIView

@property (assign, nonatomic, readonly) CGFloat progress;

@property (strong, nonatomic) UIColor *progressBarColor;

- (void)setProgress:(CGFloat)progress
           animated:(BOOL)animated;

@end
