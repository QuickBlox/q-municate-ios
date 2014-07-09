//
//  QMFriendsListDataSource.m
//  Q-municate
//
//  Created by lysenko.mykhayl on 4/3/14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMFriendsListDataSource.h"
#import "QMUsersService.h"
#import "QMFriendListCell.h"
#import "QMSearchGlobalCell.h"
#import "QMNotResultCell.h"
#import "QMApi.h"
#import "QMUsersService.h"
#import "SVProgressHud.h"
#import "QMChatReceiver.h"

static NSString *const kFriendsListCellIdentifier = @"QMFriendListCell";
static NSString *const kQMSearchGlobalCellIdentifier = @"QMSearchGlobalCell";
static NSString *const kQMNotResultCellIdentifier = @"QMNotResultCell";

@interface QMFriendsListDataSource()

<QMFriendListCellDelegate>

@property (strong, nonatomic) NSMutableArray *searchDatasource;
@property (strong, nonatomic, readonly) NSArray *friendsDatasource;

@property (weak, nonatomic) UITableView *tableView;
@end

@implementation QMFriendsListDataSource

- (instancetype)initWithTableView:(UITableView *)tableView {
    
    self = [super init];
    if (self) {
        
        self.tableView = tableView;
        self.tableView.dataSource = self;
        
        self.searchDatasource = [NSMutableArray array];
        
        [[QMChatReceiver instance] chatContactListDidChangeWithTarget:self block:^(QBContactList *contactList) {
            
            [[QMApi instance] retrieveUsersIfNeededWithContactList:contactList completion:^(BOOL updated) {
                
                if (updated) {
                    [self.tableView reloadData];
                } else {
                    if (self.friendsDatasource.count == 0 && !self.searchActive) {
                        self.tableView.tableFooterView = [self.tableView dequeueReusableCellWithIdentifier:kQMNotResultCellIdentifier];
                    }
                }
            }];
        }];
    }
    
    return self;
}

- (NSArray *)sortUsersByFullname:(NSArray *)users {
    
    NSSortDescriptor *fullNameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"fullName" ascending:YES];
    NSArray *sortedUsers = [users sortedArrayUsingDescriptors:@[fullNameDescriptor]];
    
    return sortedUsers;
}

- (void)globalSearch {
    
    QBUUserPagedResultBlock userPagedBlock = ^(QBUUserPagedResult *pagedResult) {
        
        if (pagedResult.success) {
            self.searchDatasource = [self sortUsersByFullname:pagedResult.users].mutableCopy;
            [self.tableView reloadData];
        }
        
        [SVProgressHUD dismiss];

    };
    
    PagedRequest *request = [[PagedRequest alloc] init];
    request.page = 1;
    request.perPage = 100;
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];

    if (self.searchText.length == 0) {
        [[QMApi instance].usersService retrieveUsersWithPagedRequest:request completion:userPagedBlock];
    } else {
        [[QMApi instance].usersService retrieveUsersWithFullName:self.searchText pagedRequest:request completion:userPagedBlock];
    }
}

- (void)showSearchGloblButton:(BOOL)isShow {
    
    self.tableView.tableFooterView = isShow ?
    [self.tableView dequeueReusableCellWithIdentifier:kQMSearchGlobalCellIdentifier] :
    [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)setSearchActive:(BOOL)searchActive {
    
    if (searchActive != _searchActive) {
        _searchActive = searchActive;
        [self showSearchGloblButton:searchActive];
    }
}

- (NSArray *)friendsDatasource {
    
    NSArray *allFriends = [[QMApi instance] allFriends];
    
    if (self.searchActive && self.searchText.length > 0) {

        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.fullName CONTAINS[cd] %@", self.searchText];
        NSArray *filtered = [allFriends filteredArrayUsingPredicate:predicate];
        NSArray *sortered = [self sortUsersByFullname:filtered];
        
        return sortered;
    }
    
    return allFriends;
}

- (void)setSearchText:(NSString *)searchText {
    
    if (_searchText != searchText) {
        _searchText = searchText;
    }
}

#pragma mark - UITableViewDataSource

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if (self.searchActive) {
        return (section == 0) ? kTableHeaderFriendsString : kTableHeaderAllUsersString;
    }
    
    return @"";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self usersAtSections:section].count;
}

- (NSArray *)usersAtSections:(NSUInteger)section {
    return (section == 0 ) ? self.friendsDatasource : self.searchDatasource;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSArray *datasource = [self usersAtSections:indexPath.section];
    QBUUser *user = datasource[indexPath.row];
    
    QMFriendListCell *cell = [tableView dequeueReusableCellWithIdentifier:kFriendsListCellIdentifier];
    
    if (user != (id)[NSNull null]) {
        cell.user = user;
        cell.isFriend = [[QMApi instance] isFriedID:user.ID];
        cell.online = [[QMApi instance] onlineStatusForFriendID:user.ID];
        cell.searchText = self.searchText;
    }
    
    cell.delegate = self;
    
    return cell;
}

#pragma mark - QMFriendListCellDelegate

- (void)friendListCell:(QMFriendListCell *)cell pressAddBtn:(UIButton *)sender {
    
   BOOL success = [[QMApi instance] addUserInContactListWithUserID:cell.user.ID];

    if (success) {
        NSLog(@"");
    }
}

@end
