//
//  QMCornerButton.h
//  Q-municate
//
//  Created by Injoit on 27.02.15.
//  Copyright © 2015 QuickBlox. All rights reserved.
//

#import <UIKit/UIKit.h>
IB_DESIGNABLE
@interface QMCornerButton : UIButton

@property (nonatomic) IBInspectable CGFloat cornerRadius;
@property (nonatomic) IBInspectable NSUInteger borderWidth;
@property (nonatomic) IBInspectable UIColor *borderColor;
@property (nonatomic) IBInspectable UIColor *highlightedColor;

@end
