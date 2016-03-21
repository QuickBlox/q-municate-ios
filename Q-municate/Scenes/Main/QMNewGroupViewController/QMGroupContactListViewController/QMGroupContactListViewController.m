//
//  QMGroupContactListViewController.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 3/18/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMGroupContactListViewController.h"
#import "QMGroupContactListSearchDataSource.h"
#import "QMNewMessageSearchDataProvider.h"

#import "QMSelectableContactCell.h"
#import "QMNoResultsCell.h"

@interface QMGroupContactListViewController ()

<
UITableViewDelegate,
UIScrollViewDelegate,
QMSearchDataProviderDelegate
>

@property (strong, nonatomic) QMGroupContactListSearchDataSource *dataSource;

@end

@implementation QMGroupContactListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self registerNibs];
    
    // Hide empty separators
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    // setting up data sources
    [self configureDataSources];
    
    // setting up delegate
    self.tableView.delegate = self;
}

- (void)configureDataSources {
    
    QMNewMessageSearchDataProvider *dataProvider = [[QMNewMessageSearchDataProvider alloc] init];
    dataProvider.delegate = self;
    
    self.dataSource = [[QMGroupContactListSearchDataSource alloc] initWithSearchDataProvider:dataProvider usingKeyPath:kQMQBUUserFullNameKeyPathKey];
    self.tableView.dataSource = self.dataSource;
    
    [self.dataSource replaceItems:dataProvider.friends];
}

#pragma mark - Methods

- (void)deselectUser:(QBUUser *)user {
    
    [self.dataSource deselectUser:user];
    
    // perform animated check if cell is visible and data soruce is not empty
    if (!self.dataSource.isEmpty) {
        
        for (QMSelectableContactCell *cell in self.tableView.visibleCells) {
            
            if (cell.userID == user.ID) {
                
                [cell setChecked:NO animated:YES];
            }
        }
    }
}

- (void)performSearch:(NSString *)searchText {
    
    [self.dataSource.searchDataProvider performSearch:searchText];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    QMSelectableContactCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    BOOL userSelected = [self.dataSource isSelectedUserAtIndexPath:indexPath];
    
    [self.dataSource setSelected:!userSelected userAtIndexPath:indexPath];
    [cell setChecked:!userSelected animated:YES];
    
    QBUUser *user = [self.dataSource userAtIndexPath:indexPath];
    if (userSelected) {
        
        if ([self.delegate respondsToSelector:@selector(groupContactListViewController:didDeselectUser:)]) {
            
            [self.delegate groupContactListViewController:self didDeselectUser:user];
        }
    }
    else {
        
        if ([self.delegate respondsToSelector:@selector(groupContactListViewController:didSelectUser:)]) {
            
            [self.delegate groupContactListViewController:self didSelectUser:user];
        }
    }
}

- (CGFloat)tableView:(UITableView *)__unused tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return [self.dataSource heightForRowAtIndexPath:indexPath];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    if ([self.delegate respondsToSelector:@selector(groupContactListViewController:didScrollContactList:)]) {
        
        [self.delegate groupContactListViewController:self didScrollContactList:scrollView];
    }
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
    
    if ([self.delegate respondsToSelector:@selector(groupContactListViewController:didScrollContactList:)]) {
        
        [self.delegate groupContactListViewController:self didScrollContactList:scrollView];
    }
}

#pragma mark - QMSearchDataProviderDelegate

- (void)searchDataProvider:(QMSearchDataProvider *)__unused searchDataProvider didUpdateData:(NSArray *)data {
    
    // update selected users
    NSArray *enumerateSelectedUsers = self.dataSource.selectedUsers.allObjects;
    for (QBUUser *selectedUser in enumerateSelectedUsers) {
        
        if (![data containsObject:selectedUser]) {
            
            [self.dataSource deselectUser:selectedUser];
            
            if ([self.delegate respondsToSelector:@selector(groupContactListViewController:didDeselectUser:)]) {
                
                [self.delegate groupContactListViewController:self didDeselectUser:selectedUser];
            }
        }
    }
    
    [self.tableView reloadData];
}

- (void)searchDataProviderDidFinishDataFetching:(QMSearchDataProvider *)__unused searchDataProvider {
    
    [self.tableView reloadData];
}

#pragma mark - Register nibs

- (void)registerNibs {
    
    [QMNoResultsCell registerForReuseInTableView:self.tableView];
}

@end
