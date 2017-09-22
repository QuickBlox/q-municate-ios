//
//  QMContactsViewController.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 5/16/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMContactsViewController.h"
#import "QMContactsDataSource.h"
#import "QMContactsSearchDataSource.h"
#import "QMGlobalSearchDataSource.h"
#import "QMContactsSearchDataProvider.h"

#import "QMUserInfoViewController.h"
#import "QMSearchResultsController.h"

#import "QMCore.h"
#import "QMTasks.h"
#import "QMAlert.h"
#import "QMHelpers.h"

#import "QMContactCell.h"
#import "QMNoContactsCell.h"
#import "QMNoResultsCell.h"
#import "QMSearchCell.h"

#import <SVProgressHUD.h>

typedef NS_ENUM(NSUInteger, QMSearchScopeButtonIndex) {
    
    QMSearchScopeButtonIndexLocal,
    QMSearchScopeButtonIndexGlobal
};

@interface QMContactsViewController ()

<
QMSearchResultsControllerDelegate,

UISearchControllerDelegate,
UISearchResultsUpdating,
UISearchBarDelegate,

QMContactListServiceDelegate,
QMUsersServiceDelegate
>

@property (strong, nonatomic) UISearchController *searchController;
@property (strong, nonatomic) QMSearchResultsController *searchResultsController;

/**
 *  Data sources
 */
@property (strong, nonatomic) QMContactsDataSource *dataSource;
@property (strong, nonatomic) QMContactsSearchDataSource *contactsSearchDataSource;
@property (strong, nonatomic) QMGlobalSearchDataSource *globalSearchDataSource;

@property (weak, nonatomic) BFTask *addUserTask;

@end

@implementation QMContactsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Hide empty separators
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    // search implementation
    [self configureSearch];
    
    // setting up data source
    [self configureDataSources];
    
    // filling data source
    [self updateItemsFromContactList];
    
    // registering nibs for current VC and search results VC
    [self registerNibs];
    
    // subscribing for delegates
    [QMCore.instance.contactListService addDelegate:self];
    [QMCore.instance.usersService addDelegate:self];
    
    // adding refresh control task
    if (self.refreshControl) {
        
        self.refreshControl.backgroundColor = [UIColor clearColor];
        [self.refreshControl addTarget:self
                                action:@selector(updateContactsAndEndRefreshing)
                      forControlEvents:UIControlEventValueChanged];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.searchController.isActive) {
        
        self.tabBarController.tabBar.hidden = YES;
        
        // smooth rows deselection
        [self qm_smoothlyDeselectRowsForTableView:self.searchResultsController.tableView];
    }
    else {
        
        // smooth rows deselection
        [self qm_smoothlyDeselectRowsForTableView:self.tableView];
    }
    
    if (self.refreshControl.isRefreshing) {
        // fix for freezing refresh control after tab bar switch
        // if it is still active
        CGPoint offset = self.tableView.contentOffset;
        [self.refreshControl endRefreshing];
        [self.refreshControl beginRefreshing];
        self.tableView.contentOffset = offset;
    }
}

- (void)configureSearch {
    
    self.searchResultsController = [[QMSearchResultsController alloc] init];
    self.searchResultsController.delegate = self;
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:self.searchResultsController];
    self.searchController.searchBar.placeholder = NSLocalizedString(@"QM_STR_SEARCH_BAR_PLACEHOLDER", nil);
    self.searchController.searchBar.delegate = self;
    self.searchController.searchResultsUpdater = self;
    self.searchController.delegate = self;
    self.searchController.searchBar.scopeButtonTitles = @[NSLocalizedString(@"QM_STR_LOCAL_SEARCH", nil), NSLocalizedString(@"QM_STR_GLOBAL_SEARCH", nil)];
    [self.searchController.searchBar sizeToFit]; // iOS8 searchbar sizing
    
    
#ifdef __IPHONE_11_0
    if (iosMajorVersion() >= 11) {
        
        if (@available(iOS 11.0, *)) {
            self.navigationItem.searchController = self.searchController;
            self.navigationItem.hidesSearchBarWhenScrolling = NO;
        }
        
    }
    else {
        self.tableView.tableHeaderView = self.searchController.searchBar;
    }
#else
    self.tableView.tableHeaderView = self.searchController.searchBar;
#endif
    
    self.definesPresentationContext = YES;
}

- (void)configureDataSources {
    
    self.dataSource = [[QMContactsDataSource alloc] initWithKeyPath:@keypath(QBUUser.new, fullName)];
    self.tableView.dataSource = self.dataSource;
    
    QMContactsSearchDataProvider *searchDataProvider = [[QMContactsSearchDataProvider alloc] init];
    searchDataProvider.delegate = self.searchResultsController;
    
    self.contactsSearchDataSource = [[QMContactsSearchDataSource alloc] initWithSearchDataProvider:searchDataProvider usingKeyPath:@keypath(QBUUser.new, fullName)];
    
    QMGlobalSearchDataProvider *globalSearchDataProvider = [[QMGlobalSearchDataProvider alloc] init];
    globalSearchDataProvider.delegate = self.searchResultsController;
    
    self.globalSearchDataSource = [[QMGlobalSearchDataSource alloc] initWithSearchDataProvider:globalSearchDataProvider];
    
    @weakify(self);
    self.globalSearchDataSource.didAddUserBlock = ^(UITableViewCell *cell) {
        
        @strongify(self);
        if (self.addUserTask) {
            // task in progress
            return;
        }
        
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
        
        NSIndexPath *indexPath = [self.searchResultsController.tableView indexPathForCell:cell];
        QBUUser *user = self.globalSearchDataSource.items[indexPath.row];
        
        self.addUserTask = [[QMCore.instance.contactManager addUserToContactList:user] continueWithBlock:^id _Nullable(BFTask * _Nonnull task) {
            
            [SVProgressHUD dismiss];
            
            if (!task.isFaulted
                && self.searchController.isActive
                && [self.searchResultsController.tableView.dataSource conformsToProtocol:@protocol(QMGlobalSearchDataSourceProtocol)]) {
                
                [self.searchResultsController.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            else {
                
                if (QBChat.instance.isConnected) {
                    
                    if ([QMCore.instance isInternetConnected]) {
                        
                        [QMAlert showAlertWithMessage:NSLocalizedString(@"QM_STR_CHAT_SERVER_UNAVAILABLE", nil) actionSuccess:NO inViewController:self];
                    }
                    else {
                        
                        [QMAlert showAlertWithMessage:NSLocalizedString(@"QM_STR_CHECK_INTERNET_CONNECTION", nil) actionSuccess:NO inViewController:self];
                    }
                }
                else if (QBChat.instance.isConnecting) {
                    
                    [QMAlert showAlertWithMessage:NSLocalizedString(@"QM_STR_CONNECTION_IN_PROGRESS", nil) actionSuccess:NO inViewController:self];
                }
            }
            
            return nil;
        }];
    };
}

//MARK: - Update items

- (void)updateItemsFromContactList {
    
    NSArray *friends = [QMCore.instance.contactManager friends];
    [self.dataSource replaceItems:friends];
}

//MARK: - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)__unused tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return [self.searchDataSource heightForRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)__unused tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    QBUUser *user = [(id <QMContactsSearchDataSourceProtocol>)self.searchDataSource userAtIndexPath:indexPath];
    
    [self performSegueWithIdentifier:kQMSceneSegueUserInfo sender:user];
}

//MARK: - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)__unused scrollView {
    
    [self.searchController.searchBar endEditing:YES];
}

//MARK: - UISearchControllerDelegate

- (void)willPresentSearchController:(UISearchController *)searchController {
    
    if (searchController.searchBar.scopeButtonTitles.count == 0) {
        // there is an Apple bug when first time configuring search bar scope buttons
        // will be displayed no matter what with minimal searchbar
        // to fix this adding scope buttons right before user activates search bar
        searchController.searchBar.showsScopeBar = NO;
        searchController.searchBar.scopeButtonTitles = @[NSLocalizedString(@"QM_STR_LOCAL_SEARCH", nil), NSLocalizedString(@"QM_STR_GLOBAL_SEARCH", nil)];
    }
    
    [self updateDataSourceByScope:searchController.searchBar.selectedScopeButtonIndex];
    
    self.tabBarController.tabBar.hidden = YES;
}

- (void)willDismissSearchController:(UISearchController *)__unused searchController {
    
    self.tableView.dataSource = self.dataSource;
    [self updateItemsFromContactList];
    
    self.tabBarController.tabBar.hidden = NO;
}

//MARK: - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)__unused searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope {
    
    [self updateDataSourceByScope:selectedScope];
    [self.searchResultsController performSearch:self.searchController.searchBar.text];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)__unused searchBar {
    
    [self.globalSearchDataSource.globalSearchDataProvider cancel];
}

//MARK: - QMSearchResultsControllerDelegate

- (void)searchResultsController:(QMSearchResultsController *)__unused searchResultsController willBeginScrollResults:(UIScrollView *)__unused scrollView {
    
    [self.searchController.searchBar endEditing:YES];
}

- (void)searchResultsController:(QMSearchResultsController *)__unused searchResultsController didSelectObject:(id)object {
    
    [self performSegueWithIdentifier:kQMSceneSegueUserInfo sender:object];
}

//MARK: - Helpers

- (void)updateDataSourceByScope:(NSUInteger)selectedScope {
    
    if (selectedScope == QMSearchScopeButtonIndexLocal) {
        
        [self.globalSearchDataSource.globalSearchDataProvider cancel];
        self.searchResultsController.tableView.dataSource = self.contactsSearchDataSource;
    }
    else if (selectedScope == QMSearchScopeButtonIndexGlobal) {
        
        self.searchResultsController.tableView.dataSource = self.globalSearchDataSource;
    }
    else {
        
        NSAssert(nil, @"Unknown selected scope");
    }
    
    [self.searchResultsController.tableView reloadData];
}

- (void)updateContactsAndEndRefreshing {
    
    @weakify(self);
    [[QMTasks taskUpdateContacts] continueWithBlock:^id _Nullable(BFTask * _Nonnull __unused task) {
        
        @strongify(self);
        
        [self.refreshControl endRefreshing];
        
        return nil;
    }];
}

//MARK: - Actions

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:kQMSceneSegueUserInfo]) {
        
        UINavigationController *navigationController = segue.destinationViewController;
        QMUserInfoViewController *userInfoVC = navigationController.viewControllers.firstObject;
        userInfoVC.user = sender;
    }
}

//MARK: - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    
    if (searchController.searchBar.selectedScopeButtonIndex == QMSearchScopeButtonIndexGlobal
        && !QMCore.instance.isInternetConnected) {
        
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"QM_STR_CHECK_INTERNET_CONNECTION", nil)];
        return;
    }
    
    [self.searchResultsController performSearch:searchController.searchBar.text];
}

//MARK: - QMContactListServiceDelegate

- (void)contactListService:(QMContactListService *)__unused contactListService contactListDidChange:(QBContactList *)__unused contactList {
    
    [self updateItemsFromContactList];
    [self.tableView reloadData];
}

//MARK: - QMUsersServiceDelegate

- (void)usersService:(QMUsersService *)__unused usersService didLoadUsersFromCache:(NSArray<QBUUser *> *)__unused users {
    
    [self updateItemsFromContactList];
    [self.tableView reloadData];
}

- (void)usersService:(QMUsersService *)__unused usersService didAddUsers:(NSArray<QBUUser *> *)__unused users {
    
    [self updateItemsFromContactList];
    [self.tableView reloadData];
}

- (void)usersService:(QMUsersService *)__unused usersService didUpdateUsers:(NSArray<QBUUser *> *)users {
    
    [self updateItemsFromContactList];
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

//MARK: - QMSearchProtocol

- (QMSearchDataSource *)searchDataSource {
    
    return (id)self.tableView.dataSource;
}

//MARK: - Nib registration

- (void)registerNibs {
    
    [QMContactCell registerForReuseInTableView:self.tableView];
    [QMContactCell registerForReuseInTableView:self.searchResultsController.tableView];
    
    [QMNoResultsCell registerForReuseInTableView:self.tableView];
    [QMNoResultsCell registerForReuseInTableView:self.searchResultsController.tableView];
    
    [QMSearchCell registerForReuseInTableView:self.tableView];
    [QMSearchCell registerForReuseInTableView:self.searchResultsController.tableView];
    
    [QMNoContactsCell registerForReuseInTableView:self.tableView];
}

@end
