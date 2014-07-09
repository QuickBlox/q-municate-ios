//
//  QMFriendsListDataSource.h
//  Q-municate
//
//  Created by lysenko.mykhayl on 4/3/14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//


@interface QMFriendsListDataSource : NSObject <UITableViewDataSource>

@property (weak, nonatomic, readonly) UITableView *tableView;
@property (strong, nonatomic) NSString *searchText;
@property (assign, nonatomic) BOOL searchActive;

- (void)globalSearch;
- (instancetype)initWithTableView:(UITableView *)tableView;
- (NSArray *)usersAtSections:(NSUInteger)section;

@end
