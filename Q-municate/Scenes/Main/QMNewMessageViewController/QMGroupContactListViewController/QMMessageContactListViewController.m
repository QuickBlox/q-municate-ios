//
//  QMNewMessageContactListViewController.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 3/18/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMMessageContactListViewController.h"
#import "QMNewMessageContactListSearchDataSource.h"
#import "QMContactsSearchDataProvider.h"

#import "QMSelectableContactCell.h"
#import "QMNoResultsCell.h"

#import "QMCore.h"

@interface QMMessageContactListViewController ()

<
UITableViewDelegate,
UIScrollViewDelegate,
QMSearchDataProviderDelegate,
QMUsersServiceDelegate
>

@property (strong, nonatomic) QMNewMessageContactListSearchDataSource *dataSource;

@end

@implementation QMMessageContactListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [QMCore.instance.usersService addDelegate:self];
    
    [self registerNibs];
    
    // Hide empty separators
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    // setting up data sources
    [self configureDataSources];
}

- (void)configureDataSources {
    
    QMContactsSearchDataProvider *dataProvider = [[QMContactsSearchDataProvider alloc] init];
    dataProvider.delegate = self;
    
    self.dataSource = [[QMNewMessageContactListSearchDataSource alloc] initWithSearchDataProvider:dataProvider usingKeyPath:@keypath(QBUUser.new, fullName)];
    self.tableView.dataSource = self.dataSource;
    
    [self.dataSource replaceItems:dataProvider.friends];
}

//MARK: - Methods

- (void)deselectUser:(QBUUser *)user {
    
    [self.dataSource deselectUser:user];
    
    // perform animated check if cell is visible and data soruce is not empty
    if (!self.dataSource.isEmpty) {
        
        for (QMSelectableContactCell *cell in self.tableView.visibleCells) {
            
            NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
            QBUUser *cellUser = [self.dataSource userAtIndexPath:indexPath];
            
            if (cellUser.ID == user.ID) {
                
                [cell setChecked:NO animated:YES];
            }
        }
    }
}

- (void)performSearch:(NSString *)searchText {
    
    [self.dataSource.searchDataProvider performSearch:searchText];
}

//MARK: - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    QMSelectableContactCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    BOOL userSelected = [self.dataSource isSelectedUserAtIndexPath:indexPath];
    
    [self.dataSource setSelected:!userSelected userAtIndexPath:indexPath];
    [cell setChecked:!userSelected animated:YES];
    
    QBUUser *user = [self.dataSource userAtIndexPath:indexPath];
    if (userSelected) {
        
        [self.delegate messageContactListViewController:self didDeselectUser:user];
    }
    else {
        
        [self.delegate messageContactListViewController:self didSelectUser:user];
    }
}

- (CGFloat)tableView:(UITableView *)__unused tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return [self.dataSource heightForRowAtIndexPath:indexPath];
}

//MARK: - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    [self.delegate messageContactListViewController:self didScrollContactList:scrollView];
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
    
    [self.delegate messageContactListViewController:self didScrollContactList:scrollView];
}

//MARK: - QMSearchDataProviderDelegate

- (void)searchDataProviderDidFinishDataFetching:(QMSearchDataProvider *)__unused searchDataProvider {
    
    [self.tableView reloadData];
}

- (void)searchDataProvider:(QMSearchDataProvider *)__unused searchDataProvider didUpdateData:(NSArray *)data {
    
    [self.dataSource replaceItems:data];
    
    // update selected users
    NSArray *enumerateSelectedUsers = self.dataSource.selectedUsers.allObjects;
    for (QBUUser *selectedUser in enumerateSelectedUsers) {
        
        if (![data containsObject:selectedUser]) {
            
            [self.dataSource deselectUser:selectedUser];
            
            [self.delegate messageContactListViewController:self didDeselectUser:selectedUser];
        }
    }
    
    [self.tableView reloadData];
}

// MARK: QMUsersServiceDelegate

- (void)usersService:(QMUsersService *)__unused usersService didUpdateUsers:(NSArray<QBUUser *> *)users {
    
    NSMutableArray *indexPaths = [[NSMutableArray alloc] initWithCapacity:users.count];
    for (QBUUser *user in users) {
        NSIndexPath *indexPath = [self.dataSource indexPathForObject:user];
        if (indexPath != nil) {
            [indexPaths addObject:indexPath];
        }
    }
    if (indexPaths.count > 0) {
        [self.tableView reloadRowsAtIndexPaths:[indexPaths copy] withRowAnimation:UITableViewRowAnimationNone];
    }
}

//MARK: - Register nibs

- (void)registerNibs {
    
    [QMSelectableContactCell registerForReuseInTableView:self.tableView];
    [QMNoResultsCell registerForReuseInTableView:self.tableView];
}

@end
