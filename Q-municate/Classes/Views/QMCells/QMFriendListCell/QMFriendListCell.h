//
//  QMFriendListCell.h
//  Q-municate
//
//  Created by Igor Alefirenko on 25/02/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMUserCell.h"

@class QMFriendListCell;

@protocol QMFriendListCellDelegate <NSObject>

- (void)friendListCell:(QMFriendListCell *)cell pressAddBtn:(UIButton *)sender;

@end

@interface QMFriendListCell : QMUserCell

@property (strong, nonatomic) QBContactListItem *contactlistItem;
@property (strong, nonatomic) NSString *searchText;

@property (weak, nonatomic) id <QMFriendListCellDelegate>delegate;

@end
