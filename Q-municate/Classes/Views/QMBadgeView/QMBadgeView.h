//
//  QMBadgeView.h
//  Q-municate
//
//  Created by Andrey Ivanov on 01.04.15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE
@interface QMBadgeView : UIView

@property (assign, nonatomic) IBInspectable NSUInteger cornerRadius;
@property (assign, nonatomic) IBInspectable NSUInteger borderWidth;
@property (strong, nonatomic) IBInspectable NSString *badgeText;

@end
