//
//  QMFriendListCell.h
//  Q-municate
//
//  Created by Igor Alefirenko on 25/02/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMTableViewCell.h"

@class QMFriendListCell;

@protocol QMUsersListCellDelegate <NSObject>

- (void)usersListCell:(QMTableViewCell *)cell pressAddBtn:(UIButton *)sender;

@end

@interface QMFriendListCell : QMTableViewCell

@property (strong, nonatomic) NSString *searchText;

@property (weak, nonatomic) id <QMUsersListCellDelegate>delegate;

@end
