//
//  SexyTooltip.h
//  SexyTooltip
//
//  Created by JP McGlone on 10/21/14.
//  Copyright (c) 2014 Clinkle. All rights reserved.
//

/**
 * Easily display custom tooltips at views, rects, or points.
 *
 * EXAMPLE:
 *
 * // Setup tooltip
 * SexyTooltip *tooltip = [[SexyTooltip alloc] initWithView:self.instructionsView];
 * tooltip.permittedArrowDirections = @[@(SexyTooltipArrowDirectionDown), @(SexyTooltipArrowDirectionUp)];
 *
 * // Present tooltip
 * [tooltip presentFromView:self.textField withMargin:5];
 * // [tooltip presentFromRect:CGRectInset(self.textField.frame, -5, -5) inView:self.textField.superview];
 *
 */

#import <UIKit/UIKit.h>

#define kSexyTooltipDismissDurationExpand 0.1
#define kSexyTooltipDismissDurationShrink 0.15
#define kSexyTooltipDismissDurationTotal (kSexyTooltipDismissDurationExpand + kSexyTooltipDismissDurationExpand)

@class SexyTooltip;
@protocol SexyTooltipDelegate <NSObject>

@optional
- (void)tooltipDidPresent:(SexyTooltip *)tooltip;
- (void)tooltipDidDismiss:(SexyTooltip *)tooltip;
- (void)tooltipWillBeTapped:(SexyTooltip *)tooltip;
- (void)tooltipWasTapped:(SexyTooltip *)tooltip;

@end

typedef NS_ENUM(NSUInteger, SexyTooltipArrowDirection) {
    SexyTooltipArrowDirectionUp,
    SexyTooltipArrowDirectionDown,
    SexyTooltipArrowDirectionLeft,
    SexyTooltipArrowDirectionRight
};

@interface SexyTooltip : UIView

@property (nonatomic, weak) id<SexyTooltipDelegate> delegate;

@property (nonatomic, strong) UIView *contentView; // the content to display in the tooltip, e.g. UILabel
@property (nonatomic, readonly) BOOL isShowing;

// Common configurations
@property (nonatomic, copy) UIColor *color; // Defaults to white
@property (nonatomic, copy) UIColor *borderColor; // Defaults to clearColor
@property (nonatomic, assign) UIEdgeInsets padding; // Defaults to UIEdgeInsetsMake(18, 24, 18, 24);

// Advanced configurations
@property (nonatomic, assign) CGFloat arrowHeight; //  Defaults to 5
@property (nonatomic, assign) CGFloat cornerRadius; // Defaults to 2
@property (nonatomic, assign) CGFloat arrowMargin; // The margin around the 'view' you are presenting from, defaults to 5
@property (nonatomic, assign) UIEdgeInsets margin; // The margin between the tooltip and the 'view' you are presenting in, defaults to 10

@property (nonatomic, assign) BOOL attachedToView; // Defaults to YES, if attached to the tooltip's view, the tooltip will move when the view moves
@property (nonatomic, assign) BOOL hasShadow; // setter adds and removes shadow
@property (nonatomic, assign) BOOL dismissesOnTap; // defaults to YES

@property (nonatomic, readonly) NSAttributedString *attributedString;

// permittedArrowDirections maintains ordering, otherwise works just like UIPopoverController
// defaults to [down, up, right, left]
@property (nonatomic, strong) NSArray *permittedArrowDirections;

- (id)initWithContentView:(UIView *)contentView;

- (id)initWithAttributedString:(NSAttributedString *)attrStr NS_EXTENSION_UNAVAILABLE_IOS("Not available in app extensions.");;
- (id)initWithAttributedString:(NSAttributedString *)attrStr
                   sizedToView:(UIView *)containerView;
- (id)initWithAttributedString:(NSAttributedString *)attrStr
                   sizedToView:(UIView *)containerView
                   withPadding:(UIEdgeInsets)padding
                     andMargin:(UIEdgeInsets)margin;

// Presents from a view's frame in the view's superview. If you need to present in a view that isn't the superview,
// please use 'presentFromRect:inView: and just convert your view.frame to the inView's coordinates
- (void)presentFromView:(UIView *)fromView inView:(UIView *)view withMargin:(CGFloat)margin animated:(BOOL)animated;
- (void)presentFromView:(UIView *)fromView inView:(UIView *)view animated:(BOOL)animated;
- (void)presentFromView:(UIView *)fromView inView:(UIView *)view;

// for the following, inView is assumed to be 'view.superview'
- (void)presentFromView:(UIView *)view withMargin:(CGFloat)margin animated:(BOOL)animated;
- (void)presentFromView:(UIView *)view withMargin:(CGFloat)margin;
- (void)presentFromView:(UIView *)view animated:(BOOL)animated;
- (void)presentFromView:(UIView *)view;

@property (nonatomic, strong, readonly) UIView *fromView; // the view, if any, that the tooltip is showing from

// Presents from a rect in a given view
- (void)presentFromRect:(CGRect)rect inView:(UIView *)view;
- (void)presentFromRect:(CGRect)rect inView:(UIView *)view animated:(BOOL)animated;

// Presents from a point in a given view
- (void)presentFromPoint:(CGPoint)point inView:(UIView *)view;
- (void)presentFromPoint:(CGPoint)point inView:(UIView *)view animated:(BOOL)animated;

// Dismisses the tooltip
- (void)dismiss;
- (void)dismissAnimated:(BOOL)animated;
- (void)dismissInTimeInterval:(NSTimeInterval)timeInterval;
- (void)dismissInTimeInterval:(NSTimeInterval)timeInterval animated:(BOOL)animated;
- (void)cancelDismissTimer;

// Uses the current padding / margin to give you a maximum content view size
// @param view - the view you plan to present in
// note: this does not take into account arrow direction or arrow margin, it assumes
// your tooltip can take up the entire screen
- (CGSize)maximumContentViewSizeInView:(UIView *)view;
+ (CGSize)maximumContentViewSizeWithDefaultPaddingAndMarginsInView:(UIView *)view;

// TODO: make a more robust maximumContentSize that takes into account the arrow directions, the view/rect
// you're pointing at, and how much space is around that view but within the view you're presenting from.
// Yea, it's complicated.

@end
