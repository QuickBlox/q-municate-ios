//
//  QMCornerButton.h
//  Q-municate
//
//  Created by Andrey Ivanov on 27.02.15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>
IB_DESIGNABLE
@interface QMCornerButton : UIButton

@property (nonatomic) IBInspectable CGFloat cornerRadius;
@property (nonatomic) IBInspectable NSUInteger borderWidth;
@property (nonatomic) IBInspectable UIColor *borderColor;
@property (nonatomic) IBInspectable UIColor *highlightedColor;

@end
