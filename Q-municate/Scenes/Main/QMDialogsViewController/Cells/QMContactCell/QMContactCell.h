//
//  QMContactCell.h
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 3/1/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMTableViewCell.h"

@class QMContactCell;

@protocol QMContactCellDelegate <NSObject>

- (void)contactCell:(QMContactCell *)contactCell didTapAddButton:(UIButton *)sender;

@end

@interface QMContactCell : QMTableViewCell

@property (strong, nonatomic) QBContactListItem *contactListItem;
@property (assign, nonatomic) NSUInteger userID;
@property (weak, nonatomic) id<QMContactCellDelegate> delegate;

@end
