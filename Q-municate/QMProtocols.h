//
//  QMProtocols.h
//  Q-municate
//
//  Created by Igor Alefirenko on 18.08.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//


@class QMTableViewCell;

#ifndef Q_municate_Protocols_h
#define Q_municate_Protocols_h


@protocol QMTabBarChatDelegate <NSObject>
@optional
- (void)tabBarChatWithChatMessage:(QBChatMessage *)message chatDialog:(QBChatDialog *)dialog showTMessage:(BOOL)show;
@end

@protocol QMUsersListCellDelegate <NSObject>
@optional
- (void)usersListCell:(QMTableViewCell *)cell pressAddBtn:(UIButton *)sender;
- (void)usersListCell:(QMTableViewCell *)cell requestWasAccepted:(BOOL)accepted;

@end

#endif
