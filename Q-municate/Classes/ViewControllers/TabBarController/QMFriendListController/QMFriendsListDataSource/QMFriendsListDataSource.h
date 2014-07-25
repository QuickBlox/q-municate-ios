//
//  QMFriendsListDataSource.h
//  Q-municate
//
//  Created by Andrey Ivanov on 4/3/14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//


@interface QMFriendsListDataSource : NSObject <UITableViewDataSource>

@property (weak, nonatomic, readonly) UITableView *tableView;
@property (strong, nonatomic) NSString *searchText;
@property (assign, nonatomic) BOOL searchActive;

- (instancetype)initWithTableView:(UITableView *)tableView;
- (void)globalSearch;
- (NSArray *)usersAtSections:(NSUInteger)section;
- (QBUUser *)userAtIndexPath:(NSIndexPath *)indexPath;

@end
