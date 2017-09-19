//
//  QMGroupAddUsersViewController.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 4/20/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMGroupAddUsersViewController.h"
#import "QMNewMessageContactListSearchDataSource.h"
#import "QMGroupAddUsersSearchDataProvider.h"
#import "QMCore.h"
#import "NSArray+Intersection.h"
#import "QMNavigationController.h"

#import "QMSelectableContactCell.h"
#import "QMNoResultsCell.h"

@interface QMGroupAddUsersViewController ()
<
QMChatServiceDelegate,
QMChatConnectionDelegate,

QMSearchDataProviderDelegate,

UISearchControllerDelegate,
UISearchResultsUpdating
>

@property (strong, nonatomic) UISearchController *searchController;

@property (strong, nonatomic) QMNewMessageContactListSearchDataSource *dataSource;
@property (strong, nonatomic) QMGroupAddUsersSearchDataProvider *dataProvider;

@property (copy, nonatomic) NSArray *cachedOccupantIDs;

@property (weak, nonatomic) BFTask *task;

@end

@implementation QMGroupAddUsersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self registerNibs];
    
    // subscribe for delegates
    [QMCore.instance.chatService addDelegate:self];
    
    // caching occupant IDs
    self.cachedOccupantIDs = self.chatDialog.occupantIDs;
    
    // configure data source
    [self configureDataSource];
    
    // configure search
    [self configureSearch];
}

- (void)configureDataSource {
    
    self.dataProvider = [[QMGroupAddUsersSearchDataProvider alloc] initWithExcludedUserIDs:self.cachedOccupantIDs];
    self.dataProvider.delegate = self;
    
    self.dataSource = [[QMNewMessageContactListSearchDataSource alloc] initWithSearchDataProvider:self.dataProvider usingKeyPath:@keypath(QBUUser.new, fullName)];
    self.tableView.dataSource = self.dataSource;
    
    [self replaceUsers];
}

- (void)configureSearch {
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchBar.placeholder = NSLocalizedString(@"QM_STR_SEARCH_BAR_PLACEHOLDER", nil);
    self.searchController.searchResultsUpdater = self;
    self.searchController.delegate = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.definesPresentationContext = YES;
    [self.searchController.searchBar sizeToFit]; // iOS8 searchbar sizing
    
#ifdef __IPHONE_11_0
    if (iosMajorVersion() >= 11) {
        self.navigationItem.searchController = self.searchController;
        self.navigationItem.hidesSearchBarWhenScrolling = NO;
    }
    else {
        self.tableView.tableHeaderView = self.searchController.searchBar;
    }
#else
    self.tableView.tableHeaderView = self.searchController.searchBar;
#endif
}

- (void)updateUsers {
    
    self.cachedOccupantIDs = self.chatDialog.occupantIDs;
    self.dataProvider.excludedUserIDs = self.cachedOccupantIDs;
    [self replaceUsers];
}

- (void)replaceUsers {
    
    [self.dataSource replaceItems:self.dataProvider.users];
    
    if (self.dataProvider.users.count == 0) {
        
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
}

- (void)dealloc {
    
    [self.searchController.view removeFromSuperview];
}

//MARK: - Actions

- (IBAction)doneButtonPressed:(UIBarButtonItem *)__unused sender {
    
    if (self.task != nil) {
        // task in progress
        return;
    }
    
    [(QMNavigationController *)self.navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:NSLocalizedString(@"QM_STR_LOADING", nil) duration:0];
    
    __weak UINavigationController *navigationController = self.navigationController;
    
    @weakify(self);
    self.task = [[QMCore.instance.chatManager addUsers:self.dataSource.selectedUsers.allObjects toGroupChatDialog:self.chatDialog] continueWithBlock:^id _Nullable(BFTask * _Nonnull task) {
        
        @strongify(self);
        [(QMNavigationController *)navigationController dismissNotificationPanel];
        
        if (!task.isFaulted) {
            
            [self.navigationController popViewControllerAnimated:YES];
        }
        
        return nil;
    }];
}

//MARK: - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    
    [self.dataSource.searchDataProvider performSearch:searchController.searchBar.text];
}

//MARK: - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    QMSelectableContactCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    BOOL userSelected = [self.dataSource isSelectedUserAtIndexPath:indexPath];
    
    [self.dataSource setSelected:!userSelected userAtIndexPath:indexPath];
    [cell setChecked:!userSelected animated:YES];
    
    self.navigationItem.rightBarButtonItem.enabled = self.dataSource.selectedUsers.count > 0;
    
    // clearing text field on select
    self.searchController.searchBar.text = nil;
}

- (CGFloat)tableView:(UITableView *)__unused tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return [self.dataSource heightForRowAtIndexPath:indexPath];
}

//MARK: - QMSearchDataProviderDelegate

- (void)searchDataProviderDidFinishDataFetching:(QMSearchDataProvider *)__unused searchDataProvider {
    
    [self.tableView reloadData];
}

- (void)searchDataProvider:(QMSearchDataProvider *)__unused searchDataProvider didUpdateData:(NSArray *)data {
    
    [self replaceUsers];
    
    // update selected users
    NSArray *enumerateSelectedUsers = self.dataSource.selectedUsers.allObjects;
    for (QBUUser *selectedUser in enumerateSelectedUsers) {
        
        if (![data containsObject:selectedUser]) {
            
            [self.dataSource deselectUser:selectedUser];
        }
    }
    
    [self.tableView reloadData];
}

//MARK: - QMChatServiceDelegate

- (void)chatService:(QMChatService *)__unused chatService didUpdateChatDialogInMemoryStorage:(QBChatDialog *)chatDialog {
    
    if ([chatDialog.ID isEqualToString:self.chatDialog.ID] && ![self.chatDialog.occupantIDs isEqual:self.cachedOccupantIDs]) {
        
        [self updateUsers];
        [self.tableView reloadData];
    }
}

- (void)chatService:(QMChatService *)__unused chatService didUpdateChatDialogsInMemoryStorage:(NSArray<QBChatDialog *> *)dialogs {
    
    if ([dialogs containsObject:self.chatDialog] && ![self.chatDialog.occupantIDs isEqual:self.cachedOccupantIDs]) {
        
        [self updateUsers];
        [self.tableView reloadData];
    }
}

//MARK: - register nibs

- (void)registerNibs {
    
    [QMSelectableContactCell registerForReuseInTableView:self.tableView];
    [QMNoResultsCell registerForReuseInTableView:self.tableView];
}

@end
