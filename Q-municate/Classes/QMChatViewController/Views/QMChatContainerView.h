//
//  QMChatContainerView.h
//  QMChatViewController
//
//  Created by Injoit on 14.05.15.
//  Copyright © 2015 QuickBlox. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  Customisable chat container view.
 */
@interface QMChatContainerView : UIView

@property (strong, nonatomic) IBInspectable UIColor *bgColor;
@property (strong, nonatomic) IBInspectable UIColor *highlightColor;
@property (assign, nonatomic) IBInspectable CGFloat cornerRadius;
@property (assign, nonatomic) IBInspectable BOOL arrow;
@property (assign, nonatomic) IBInspectable BOOL leftArrow;
@property (assign, nonatomic) IBInspectable CGSize arrowSize;
@property (assign, nonatomic) BOOL highlighted;
@property (readonly, strong, nonatomic) UIImage *backgroundImage;
@property (readonly, strong, nonatomic) UIBezierPath *maskPath;


@end
