//
//  QMCallToolbar.h
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 5/10/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  QMCallToolbar class interface.
 *  Used as main toolbar for QMCallViewController.
 *
 *  @see QMCallViewController class.
 */
@interface QMCallToolbar : UIToolbar

/**
 *  Add button with action.
 *
 *  @param button UIButton instance
 *  @param action action for button press
 */
- (void)addButton:(UIButton *)button action:(void(^)(UIButton *sender))action;

/**
 *  Update items display.
 *
 *  @discussion After adding buttons they will not be visible just yet.
 *  Call this method after buttons configuration to display them in toolbar.
 */
- (void)updateItemsDisplay;

@end

NS_ASSUME_NONNULL_END
