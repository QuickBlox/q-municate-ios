//
//  QMFriendListCell.h
//  Q-municate
//
//  Created by Igor Alefirenko on 25/02/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QMFriendListCell;

@protocol QMFriendListCellDelegate <NSObject>

- (void)friendListCell:(QMFriendListCell *)cell pressAddBtn:(UIButton *)sender;

@end

@interface QMFriendListCell : UITableViewCell

@property (strong, nonatomic) QBUUser *user;
@property (strong, nonatomic) NSString *searchText;
@property (assign, nonatomic) BOOL online;
@property (assign, nonatomic) BOOL isFriend;

@property (weak, nonatomic) id <QMFriendListCellDelegate>delegate;

@end
