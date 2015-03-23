
//
//  QMFriendsListDataSource.m
//  Q-municate
//
//  Created by Andrey Ivanov on 4/3/14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMFriendsListDataSource.h"
#import "QMFriendListViewController.h"
#import "QMUsersService.h"
#import "QMFriendListCell.h"
#import "QMApi.h"
#import "QMUsersService.h"
#import "SVProgressHud.h"
#import "QMChatReceiver.h"
#import "REAlertView.h"


@interface QMFriendsListDataSource()


@property (strong, nonatomic) NSMutableArray *searchResult;
@property (strong, nonatomic) NSArray *friendList;

@property (weak, nonatomic) UITableView *tableView;
@property (weak, nonatomic) UISearchDisplayController *searchDisplayController;
@property (strong, nonatomic) NSObject<Cancelable> *searchOperation;

@property (assign, nonatomic) NSUInteger contactRequestsCount;

@end

@implementation QMFriendsListDataSource

@synthesize friendList = _friendList;

- (void)dealloc {
    ILog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
    [[QMChatReceiver instance] unsubscribeForTarget:self];
}

- (instancetype)initWithTableView:(UITableView *)tableView searchDisplayController:(UISearchDisplayController *)searchDisplayController
{
    
    self = [super init];
    if (self) {
        
        self.tableView = tableView;
        self.tableView.dataSource = self;
        self.searchResult = [NSMutableArray new];
        
        self.searchDisplayController = searchDisplayController;
        __weak __typeof(self)weakSelf = self;
        
        void (^reloadDatasource)(void) = ^(void) {
            
            if (weakSelf.searchOperation) {
                return;
            }
            
            if (self.searchDisplayController.isActive) {
                
                weakSelf.friendList = [QMApi instance].friends;
                
                [weakSelf.searchDisplayController.searchResultsTableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 2)]   withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            else {
                [weakSelf reloadDataSource];
            }
        };
        
        [[QMChatReceiver instance] usersHistoryUpdatedWithTarget:self block:reloadDatasource];
        [[QMChatReceiver instance] chatContactListUpdatedWithTarget:self block:reloadDatasource];
        
        UINib *friendsCellNib = [UINib nibWithNibName:@"QMFriendListCell" bundle:nil];
        UINib *noResultsCellNib = [UINib nibWithNibName:@"QMNoResultsCell" bundle:nil];
        
        [searchDisplayController.searchResultsTableView registerNib:friendsCellNib forCellReuseIdentifier:kQMFriendsListCellIdentifier];
        [searchDisplayController.searchResultsTableView registerNib:noResultsCellNib forCellReuseIdentifier:kQMDontHaveAnyFriendsCellIdentifier];
    }
    
    return self;
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
    if (self.viewIsShowed) {
        [self.tableView reloadData];
    }
} 

- (void)globalSearch:(NSString *)searchText {
    
    if (searchText.length == 0) {
        self.searchResult = [NSMutableArray new];
        [self.searchDisplayController.searchResultsTableView reloadData];
        return;
    }
    
    __weak __typeof(self)weakSelf = self;
    QBUUserPagedResultBlock userPagedBlock = ^(QBUUserPagedResult *pagedResult) {
        
        NSArray *users = [QMUsersUtils sortUsersByFullname:pagedResult.users];
        
        NSMutableArray *filteredUsers = [QMUsersUtils filteredUsers:users withFlterArray:[weakSelf.friendList arrayByAddingObject:[QMApi instance].currentUser]];
        
        weakSelf.searchResult = filteredUsers;
        
        [weakSelf.searchDisplayController.searchResultsTableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
        weakSelf.searchOperation = nil;
        [SVProgressHUD dismiss];
    };
    
    [self.searchDisplayController.searchResultsTableView reloadData];
    
    __block NSString *tsearch = [searchText copy];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        if ([self.searchDisplayController.searchBar.text isEqualToString:tsearch]) {
            
            if (self.searchOperation) {
                [self.searchOperation cancel];
                self.searchOperation = nil;
            }
            
            PagedRequest *request = [[PagedRequest alloc] init];
            request.page = 1;
            request.perPage = 100;
            
            
            [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
            self.searchOperation = [[QMApi instance].usersService retrieveUsersWithFullName:searchText pagedRequest:request completion:userPagedBlock];
        }
    });
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
    return cell;
}


#pragma mark - QMUsersListCellDelegate

- (void)usersListCell:(QMFriendListCell *)cell pressAddBtn:(UIButton *)sender {
    
    NSIndexPath *indexPath = [self.searchDisplayController.searchResultsTableView indexPathForCell:cell];
    NSArray *datasource = [self usersAtSections:indexPath.section];
    QBUUser *user = datasource[indexPath.row];
    self.searchResult = [QMUsersUtils filteredUsers:self.searchResult withFlterArray:@[user]];
    
    BOOL isContactRequest = [[QMApi instance].usersService isContactRequestWithID:user.ID];
    if (isContactRequest) {
        [[QMApi instance] confirmAddContactRequest:user completion:^(BOOL success, QBChatMessage *notification) {}];
    } else {
        [[QMApi instance] addUserToContactList:user completion:^(BOOL success, QBChatMessage *notification) {}];
    }
}


#pragma mark - UISearchDisplayController

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    [self globalSearch:searchString];
    return NO;
}

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
    // needed!
//    [self.tableView setDataSource:nil];
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller
{
//    [self.tableView setDataSource:self];
    [self reloadDataSource];
    [self.tableView reloadData];
}

@end
