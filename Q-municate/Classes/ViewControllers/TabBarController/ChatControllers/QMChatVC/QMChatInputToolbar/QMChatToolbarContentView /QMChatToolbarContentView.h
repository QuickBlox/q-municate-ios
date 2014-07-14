//
//  QMChatToolbarContentView.h
//  Qmunicate
//
//  Created by Andrey on 20.06.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QMChatInputTextView;

@interface QMChatToolbarContentView : UIView
/**
 *  Returns the text view in which the user enter a message.
 */
@property (strong, nonatomic, readonly) QMChatInputTextView *textView;

/**
 *  A custom button item displayed on the left of the toolbar content view.
 *
 *  @discussion The frame of this button is ignored. When you set this property, the button
 *  is fitted within a pre-defined default content view, whose height is determined by the
 *  height of the toolbar. You may specify a new width using `leftBarButtonItemWidth`.
 *  Set this value to `nil` to remove the button.
 */
@property (strong, nonatomic) UIButton *leftBarButtonItem;

/**
 *  Specifies the width of the leftBarButtonItem.
 */
@property (assign, nonatomic) CGFloat leftBarButtonItemWidth;

/**
 *  A custom button item displayed on the right of the toolbar content view.
 *
 *  @discussion The frame of this button is ignored. When you set this property, the button
 *  is fitted within a pre-defined default content view, whose height is determined by the
 *  height of the toolbar. You may specify a new width using `rightBarButtonItemWidth`.
 *  Set this value to `nil` to remove the button.
 */
@property (strong, nonatomic) UIButton *rightBarButtonItem;

/**
 *  Specifies the width of the rightBarButtonItem.
 */
@property (assign, nonatomic) CGFloat rightBarButtonItemWidth;


@end
