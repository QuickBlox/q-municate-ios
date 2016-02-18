
//
//  QMFriendsListDataSource.m
//  Q-municate
//
//  Created by Andrey Ivanov on 4/3/14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMFriendsListDataSource.h"
#import "QMFriendListViewController.h"
#import "QMFriendListCell.h"
#import "QMApi.h"
#import "QMUsersUtils.h"
#import "SVProgressHud.h"
#import "REAlertView.h"
#import "REAlertView+QMSuccess.h"

static const NSUInteger kQMUsersPageLimit       = 50;
static const NSUInteger kQMGlobalSearchCharsMin = 3;

@interface QMFriendsListDataSource()
<
QMContactListServiceDelegate
>

@property (strong, nonatomic) NSMutableArray *searchResult;
@property (strong, nonatomic) NSArray *friendList;

@property (weak, nonatomic) UITableView *tableView;
@property (weak, nonatomic) UISearchDisplayController *searchDisplayController;

@property (assign, nonatomic) NSUInteger contactRequestsCount;

@property (strong, nonatomic) NSTimer* timer;

@property (assign, nonatomic) NSUInteger currentPage;
@property (assign, nonatomic) BOOL shouldLoadMore;

@end

@implementation QMFriendsListDataSource

@synthesize friendList = _friendList;

- (instancetype)initWithTableView:(UITableView *)tableView searchDisplayController:(UISearchDisplayController *)searchDisplayController
{
    
    self = [super init];
    if (self) {
        
        self.tableView = tableView;
        self.tableView.dataSource = self;
        [[QMApi instance].contactListService addDelegate:self];
        self.searchResult = [NSMutableArray array];
        
        self.searchDisplayController = searchDisplayController;

        UINib *friendsCellNib = [UINib nibWithNibName:@"QMFriendListCell" bundle:nil];
        UINib *noResultsCellNib = [UINib nibWithNibName:@"QMNoResultsCell" bundle:nil];
        
        [searchDisplayController.searchResultsTableView registerNib:friendsCellNib forCellReuseIdentifier:kQMFriendsListCellIdentifier];
        [searchDisplayController.searchResultsTableView registerNib:noResultsCellNib forCellReuseIdentifier:kQMDontHaveAnyFriendsCellIdentifier];
    }
    
    return self;
}

- (void)dealloc {
    [[QMApi instance].contactListService removeDelegate:self];
}

- (void)setFriendList:(NSArray *)friendList {
    _friendList = [QMUsersUtils sortUsersByFullname:friendList];
}

- (NSArray *)friendList {
    
    if (self.searchDisplayController.isActive && self.searchDisplayController.searchBar.text.length > 0) {
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.fullName CONTAINS[cd] %@", self.searchDisplayController.searchBar.text];
        NSArray *filtered = [_friendList filteredArrayUsingPredicate:predicate];
        
        return filtered;
    }
    return _friendList;
}

- (void)reloadDataSource {
    
    self.friendList = [QMApi instance].friends;
    
    if (self.searchDisplayController.isActive) {
        
        self.currentPage = 1;
        [self globalSearch];
    }
    else {
        
        [self.tableView reloadData];
    }
}

- (void)globalSearch
{
    if (self.searchDisplayController.searchBar.text.length < kQMGlobalSearchCharsMin) {
        [self.searchResult removeAllObjects];
        [self.searchDisplayController.searchResultsTableView reloadData];
        return;
    }
    
    @weakify(self);
    void (^userResponseBlock)(NSArray *users) = ^void(NSArray *users) {
        @strongify(self);
        if ([users count] < kQMUsersPageLimit) {
            self.shouldLoadMore = NO;
        } else {
            self.shouldLoadMore = YES;
        }
        
        NSArray *sortedUsers = [QMUsersUtils sortUsersByFullname:users];
        
        NSMutableArray *filteredUsers = [QMUsersUtils filteredUsers:sortedUsers withFlterArray:[self.friendList arrayByAddingObject:[QMApi instance].currentUser]];
        
        if (self.currentPage > 1) {
            [self.searchResult addObjectsFromArray:filteredUsers];
        } else {
            self.searchResult = filteredUsers;
        }
        
        [self.searchDisplayController.searchResultsTableView reloadData];
        
        [SVProgressHUD dismiss];
    };
    
    QBGeneralResponsePage *page = [QBGeneralResponsePage responsePageWithCurrentPage:self.currentPage perPage:kQMUsersPageLimit];
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [[[QMApi instance].usersService searchUsersWithFullName:self.searchDisplayController.searchBar.text page:page] continueWithBlock:^id(BFTask<NSArray<QBUUser *> *> *task) {
        //
        if (task.isCompleted) {
            if (userResponseBlock) userResponseBlock(task.result);
        }
        
        return nil;
    }];
}

- (void)setContactRequestsCount:(NSUInteger)contactRequestsCount
{
    if (_contactRequestsCount != contactRequestsCount) {
        _contactRequestsCount = contactRequestsCount;
        if ([self.delegate respondsToSelector:@selector(didChangeContactRequestsCount:)]) {
            [self.delegate didChangeContactRequestsCount:_contactRequestsCount];
        }
    }
}

- (void)updateView {
    if (self.searchDisplayController.isActive) {
        
        self.friendList = [QMApi instance].friends;
        
        [self.searchDisplayController.searchResultsTableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 2)]   withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else {
        [self reloadDataSource];
    }
}

#pragma mark - UITableViewDataSource

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    NSArray *users = [self usersAtSections:section];
    
    if (self.searchDisplayController.isActive && section == 1) {
        return (users.count > 0) ? NSLocalizedString(@"QM_STR_ALL_USERS", nil) : nil;
    }
    return (users.count > 0) ? NSLocalizedString(@"QM_STR_CONTACTS", nil) : nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return (self.searchDisplayController.isActive) ? 2 : 1;

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSArray *users = [self usersAtSections:section];
    if (self.searchDisplayController.isActive) {
        return (users.count > 0) ? users.count : 0;
    }
    return (users.count > 0) ? users.count : 1;
}

- (NSArray *)usersAtSections:(NSInteger)section
{
    return (section == 0) ? self.friendList : self.searchResult;
}

- (QBUUser *)userAtIndexPath:(NSIndexPath *)indexPath {
    
    NSArray *users = [self usersAtSections:indexPath.section];
    QBUUser *user = users[indexPath.row];
    
    return user;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSArray *users = [self usersAtSections:indexPath.section];
    
    if (!self.searchDisplayController.isActive) {
        if (users.count == 0) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kQMDontHaveAnyFriendsCellIdentifier];
            return cell;
        }
    }
    QMFriendListCell *cell = [tableView dequeueReusableCellWithIdentifier:kQMFriendsListCellIdentifier];
    cell.delegate = self;

    QBUUser *user = users[indexPath.row];
    
    QBContactListItem *item = [[QMApi instance] contactItemWithUserID:user.ID];
    cell.contactlistItem = item;
    cell.userData = user;
    
    if(self.searchDisplayController.isActive) {
        cell.searchText = self.searchDisplayController.searchBar.text;
    }
    
    if (tableView == self.searchDisplayController.searchResultsTableView && indexPath.section == 1 && indexPath.row == [tableView numberOfRowsInSection:1] - 1) {
        // last row in search results section
        if (self.shouldLoadMore) {
            self.currentPage++;
            [self globalSearch];
        }
    }
    
    return cell;
}

#pragma mark - QMUsersListCellDelegate

- (void)usersListCell:(QMFriendListCell *)cell pressAddBtn:(UIButton *)sender {
    
    if (![QMApi instance].isInternetConnected) {
        [REAlertView showAlertWithMessage:NSLocalizedString(@"QM_STR_CHECK_INTERNET_CONNECTION", nil) actionSuccess:NO];
        return;
    }
    
    NSIndexPath *indexPath = [self.searchDisplayController.searchResultsTableView indexPathForCell:cell];
    NSArray *datasource = [self usersAtSections:indexPath.section];
    QBUUser *user = datasource[indexPath.row];
    
    NSInteger idx = [self.searchResult indexOfObject:user];
    if (idx != NSNotFound) {
        
        [self.searchResult removeObject:user];
    }
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    BOOL isContactRequest = [[QMApi instance] isContactRequestUserWithID:user.ID];
    if (isContactRequest) {
        [[QMApi instance] confirmAddContactRequest:user completion:^(BOOL success) {
            
            if (success) {
                [SVProgressHUD showSuccessWithStatus:nil];
            }
        }];
    } else {
        [[QMApi instance] addUserToContactList:user completion:^(BOOL success, QBChatMessage *notification) {
            
            if (success) {
                [SVProgressHUD showSuccessWithStatus:nil];
            }
        }];
    }
}


#pragma mark - UISearchDisplayController

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    [self.timer invalidate];
    
    self.currentPage = 1;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.6 target:self selector:@selector(globalSearch) userInfo:nil repeats:NO];
    return NO;
}

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
    [self.tableView setDataSource:nil];
    [self reloadDataSource];
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller
{
    [self.tableView setDataSource:self];
    [self reloadDataSource];
}

#pragma mark Contact List Serice Delegate

- (void)contactListServiceDidLoadCache {
    [self updateView];
}

- (void)contactListService:(QMContactListService *)contactListService contactListDidChange:(QBContactList *)contactList {
    [self updateView];
}

@end
