//
//  QMGroupOccupantsDataSource.h
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 4/5/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMTableViewDataSource.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  QMGroupOccupantsDataSource class interface.
 *  Used as data source for group info occupants list.
 */
@interface QMGroupOccupantsDataSource : QMTableViewDataSource

/**
 *  Add member static cell index.
 */
@property (assign, nonatomic, readonly) NSInteger addMemberCellIndex;

/**
 *  Leave chat static cell index.
 */
@property (assign, nonatomic, readonly) NSInteger leaveChatCellIndex;

/**
 *  Add user block action.
 */
@property (copy, nonatomic) void (^didAddUserBlock)(UITableViewCell *cell);

/**
 *  Index for user at index path.
 *
 *  @param indexPath index path of user
 *
 *  @return index of user in items array
 */
- (NSUInteger)userIndexForIndexPath:(NSIndexPath *)indexPath;

@end

NS_ASSUME_NONNULL_END
