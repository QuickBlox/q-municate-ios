//
//  QMChatInputToolbar.h
//  Qmunicate
//
//  Created by Andrey Ivanov on 20.06.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QMChatInputToolbar;
@class QMChatToolbarContentView;
/**
 *  A constant the specifies the default height for a `QMChatInputToolbar`.
 */
FOUNDATION_EXPORT const CGFloat kQMChatInputToolbarHeightDefault;
/**
 *  The `QMChatInputToolbarDelegate` protocol defines methods for interacting with
 *  a `QMChatInputToolbar` object.
 */
@protocol QMChatInputToolbarDelegate <UIToolbarDelegate>

@required
/**
 *  Tells the delegate that the toolbar's `rightBarButtonItem` has been pressed.
 *
 *  @param toolbar The object representing the toolbar sending this information.
 *  @param sender  The button that received the touch event.
 */
- (void)chatInputToolbar:(QMChatInputToolbar *)toolbar didPressRightBarButton:(UIButton *)sender;
/**
 *  Tells the delegate that the toolbar's `leftBarButtonItem` has been pressed.
 *
 *  @param toolbar The object representing the toolbar sending this information.
 *  @param sender  The button that received the touch event.
 */
- (void)chatInputToolbar:(QMChatInputToolbar *)toolbar didPressLeftBarButton:(UIButton *)sender;

@end

@interface QMChatInputToolbar : UIToolbar
/**
 *  The object that acts as the delegate of the toolbar.
 */
@property (weak, nonatomic) id<QMChatInputToolbarDelegate> delegate;
/**
 *  Returns the content view of the toolbar. This view contains all subviews of the toolbar.
 */
@property (weak, nonatomic, readonly) QMChatToolbarContentView *contentView;
/**
 *  A boolean value indicating whether the send button is on the right side of the toolbar or not.
 *
 *  @discussion The default value is `YES`, which indicates that the send button is the right-most subview of
 *  the toolbar's `contentView`. Set to `NO` to specify that the send button is on the left. This
 *  property is used to determine which touch events correspond to which actions.
 *
 *  @warning Note, this property *does not* change the positions of buttons in the toolbar's content view.
 *  It only specifies whether the `rightBarButtonItem `or the `leftBarButtonItem` is the send button.
 *  The other button then acts as the accessory button.
 */
@property (assign, nonatomic) BOOL sendButtonOnRight;
/**
 *  Enables or disables the send button based on whether or not its `textView` has text.
 *  That is, the send button will be enabled if there is text in the `textView`, and disabled otherwise.
 */
- (void)toggleSendButtonEnabled;

/**
 * Lock input bar.
 */
- (void)lock;

/**
 * Unlock input bar.
 */
- (void)unlock;


@end
