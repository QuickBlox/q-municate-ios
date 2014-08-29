//
//  QMContactRequestDataSource.h
//  Q-municate
//
//  Created by Igor Alefirenko on 28/08/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMTableDataSource.h"

@class QMFriendsListDataSource;

@interface QMContactRequestDataSource : QMTableDataSource

- (instancetype)initWithFriendsListDataSource:(QMFriendsListDataSource *)friendsListDataSource;

@end
