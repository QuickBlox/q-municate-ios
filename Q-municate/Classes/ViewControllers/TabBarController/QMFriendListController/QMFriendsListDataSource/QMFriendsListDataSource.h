//
//  QMFriendsListDataSource.h
//  Q-municate
//
//  Created by Andrey Ivanov on 4/3/14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

static NSString *const kQMFriendsListCellIdentifier = @"QMFriendListCell";
static NSString *const kQMDontHaveAnyFriendsCellIdentifier = @"QMDontHaveAnyFriendsCell";
static NSString *const kQMContactRequestCellIdentifier = @"QMContactRequestCell";

@protocol QMFriendsListDataSourceDelegate <NSObject>

- (void)didChangeContactRequestsCount:(NSUInteger)contactRequestsCount;

@end

@interface QMFriendsListDataSource : NSObject <UITableViewDataSource, UISearchDisplayDelegate, QMUsersListDelegate>

@property (nonatomic, assign) BOOL viewIsShowed;
@property (weak, nonatomic) id <QMFriendsListDataSourceDelegate> delegate;

- (instancetype)initWithTableView:(UITableView *)tableView searchDisplayController:(UISearchDisplayController *)searchDisplayController;
- (NSArray *)usersAtSections:(NSInteger)section;
- (QBUUser *)userAtIndexPath:(NSIndexPath *)indexPath;

@end
