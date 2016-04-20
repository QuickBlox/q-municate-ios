//
//  QMContactCell.h
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 3/1/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMTableViewCell.h"

@class QMSearchCell;

@protocol QMSearchCellDelegate <NSObject>

- (void)searchCell:(QMSearchCell *)searchCell didTapAddButton:(UIButton *)sender;

@end

@interface QMSearchCell : QMTableViewCell

@property (weak, nonatomic) id<QMSearchCellDelegate> delegate;
@property (strong, nonatomic) QBUUser *user;

@end
