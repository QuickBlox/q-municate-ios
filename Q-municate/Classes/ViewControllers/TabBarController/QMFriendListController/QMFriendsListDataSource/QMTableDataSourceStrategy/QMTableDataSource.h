//
//  QMTableDataSource.h
//  Q-municate
//
//  Created by Igor Alefirenko on 28/08/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

@class QMFriendsListDataSource;

@interface QMTableDataSource : NSObject <UITableViewDataSource>

@property (nonatomic, copy) NSArray *friends;
@property (nonatomic, copy) NSArray *otherUsers;

@property (nonatomic, strong, readonly) QMFriendsListDataSource *friendsListDataSource;

- (instancetype)initWithFriendsListDataSource:(QMFriendsListDataSource *)friendsListDataSource;

@end
