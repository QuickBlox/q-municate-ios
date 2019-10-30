//
//  QMContactCell.h
//  Q-municate
//
//  Created by Injoit on 3/1/16.
//  Copyright © 2016 QuickBlox. All rights reserved.
//

#import "QMTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  QMSearchCell class interface.
 *  Used as base cell for users.
 */
@interface QMSearchCell : QMTableViewCell

/**
 *  Add user block action.
 */
@property (copy, nonatomic) void (^didAddUserBlock)(UITableViewCell *cell);

/**
 *  Set add friend button visible.
 *
 *  @param visible wheter add button should be visible or not
 */
- (void)setAddButtonVisible:(BOOL)visible;

@end

NS_ASSUME_NONNULL_END
