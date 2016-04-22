//
//  QMGroupOccupantsDataSource.h
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 4/5/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMTableViewDataSource.h"

@interface QMGroupOccupantsDataSource : QMTableViewDataSource

@property (assign, nonatomic, readonly) NSInteger addMemberCellIndex;
@property (assign, nonatomic, readonly) NSInteger leaveChatCellIndex;

- (NSUInteger)userIndexForIndexPath:(NSIndexPath *)indexPath;

@end
