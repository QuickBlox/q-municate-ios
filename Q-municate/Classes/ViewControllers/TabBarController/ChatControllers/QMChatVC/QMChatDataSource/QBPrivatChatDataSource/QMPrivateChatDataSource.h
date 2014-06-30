//
//  QMPrivateChatDataSource.h
//  Qmunicate
//
//  Created by Andrey on 16.06.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMChatDataSource.h"

@interface QMPrivateChatDataSource : QMChatDataSource

- (instancetype)initWithChatDialog:(QBChatDialog *)dialog forTableView:(UITableView *)tableView
__attribute__((unavailable("init is not a supported initializer for this class.")));

- (instancetype)initWithChatDialog:(QBChatDialog *)dialog opponent:(QBUUser *)opponent forTableView:(UITableView *)tableView;

@end
