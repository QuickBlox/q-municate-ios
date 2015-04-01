//
//  QMChatHistoryVC.m
//  Q-municate
//
//  Created by Andrey Ivanov on 11.03.15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import "QMChatHistoryVC.h"
#import "QMServicesManager.h"
#import "QMChatHistoryDatasource.h"
#import "QMSearchChatHistoryDatasource.h"
#import "QMNotificationView.h"

#import "QMContactCell.h"
#import "QMChatHistoryCell.h"
#import "QMSearchStatusCell.h"

#import "QMSearchController.h"

const NSTimeInterval kQMKeyboardTapTimeInterval = 1.f;

typedef NS_ENUM(NSUInteger, QMSearchScopeButtonIndex) {
    
    QMSearchScopeButtonIndexLocal,
    QMSearchScopeButtonIndexGlobal
};

@interface QMChatHistoryVC ()

<UITableViewDelegate, QMContactListServiceDelegate, UISearchBarDelegate, QMAddContactProtocol, QMSearchResultsUpdating, QMSearchControllerDelegate>
/**
 *  Datasources
 */
@property (strong, nonatomic) IBOutlet QMChatHistoryDatasource *historyDatasource;
@property (strong, nonatomic) IBOutlet QMSearchChatHistoryDatasource *searchDatasource;

@property (strong, nonatomic) QMNotificationView *notificationView;

@property (weak, nonatomic) QBRequest *searchRequest;
@property (assign, nonatomic) BOOL globalSearchIsCancelled;
@property (strong, nonatomic) QMSearchController *searchController;

@end

@implementation QMChatHistoryVC

#pragma mark - lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureTableView];
    [self configureSearchController];
    [self registerNibs];
    
    [QM.contactListService addDelegate:self];
    
    [QM.chatService logIn:^(NSError *error) {
        
    }];
}

#pragma mark - QMContactListServiceDelegate

- (void)contactListServiceDidLoadCache {
    
    NSArray *usersFormCache = [QM.contactListService.usersMemoryStorage unsorterdUsersFromMemoryStorage];
    [self.historyDatasource setObjects:usersFormCache];
    [self.tableView reloadData];
}

#pragma mark -

- (void)configureTableView {
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    // Hide serach bar
    self.tableView.contentOffset = CGPointMake(0, self.searchDisplayController.searchBar.frame.size.height);
    //Add refresh control
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
}

- (void)configureSearchController {
    
    self.definesPresentationContext = YES;
    self.searchController = [[QMSearchController alloc] initWithContentsController:self];
    self.searchController.delegate = self;
    self.searchController.searchResultsUpdater = self;
    self.searchController.searchResultsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.searchController.searchResultsTableView.rowHeight = 75;
    self.searchController.searchResultsDataSource = self.searchDatasource;
    self.searchController.searchBar.delegate = self;
    self.searchController.searchBar.placeholder = @"Search";
    self.searchController.searchBar.scopeButtonTitles = @[@"Local", @"Global"];
    
    self.tableView.tableHeaderView = self.searchController.searchBar;
}

- (void)registerNibs {
    
    [QMChatHistoryCell registerForReuseInTableView:self.tableView];
    [QMChatHistoryCell registerForReuseInTableView:self.searchController.searchResultsTableView];
    [QMContactCell registerForReuseInTableView:self.searchController.searchResultsTableView];
    [QMSearchStatusCell registerForReuseInTableView:self.searchController.searchResultsTableView];
}

#pragma mark - Actions
#pragma mark Refresh control

- (void)refresh:(UIRefreshControl *)sender {
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.refreshControl endRefreshing];
    });
}

#pragma mark Navigation bar actions

- (void)localSearch:(NSString *)searchText {
    
    self.globalSearchIsCancelled = YES;
    [self.searchDatasource setObjects:nil];
    self.searchDatasource.searchText = nil;
    [self.searchController.searchResultsTableView reloadData];
}

#pragma mark - Search

- (void)globalSearch:(NSString *)searchText {
    
    self.globalSearchIsCancelled = NO;
    
    if (searchText.length == 0) {
        //Clear datasource
        [self.searchDatasource setObjects:@[]];
        [self.searchController.searchResultsTableView reloadData];
    }
    else {
        
        self.searchDatasource.loading = YES;
        [self.searchController.searchResultsTableView reloadData];
        
        int64_t keyboadTapTimeInterval = (int64_t)(kQMKeyboardTapTimeInterval * NSEC_PER_SEC);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, keyboadTapTimeInterval), dispatch_get_main_queue(), ^{
            
            if ([self.searchController.searchBar.text isEqualToString:searchText]) {
                
                if (self.globalSearchIsCancelled) {
                    
                    self.globalSearchIsCancelled = NO;
                    return;
                }
                
                __weak __typeof(self)weakSelf = self;
                self.searchRequest =
                [QBRequest usersWithFullName:searchText
                                        page:[self.searchDatasource responsePage]
                                successBlock:^(QBResponse *response,
                                               QBGeneralResponsePage *page,
                                               NSArray *users)
                 {
                     [weakSelf.searchDatasource setObjects:users];
                     [weakSelf.searchDatasource setSearchText:searchText];
                     weakSelf.searchDatasource.loading = NO;
                     [weakSelf.searchController.searchResultsTableView reloadData];
                     weakSelf.searchRequest = nil;
                     
                 } errorBlock:^(QBResponse *response) {
                     
                     weakSelf.searchDatasource.loading = NO;
                     if (response.status == QBResponseStatusCodeCancelled) {
                         
                         NSLog(@"Global search is cancelled");
                     }
                 }];
            }
        });
    }
}

- (void)beginSearch:(NSString *)searchString selectedScope:(NSInteger)selectedScope {
    
    switch (selectedScope) {
            
        case QMSearchScopeButtonIndexLocal: {
            [self localSearch:searchString];
        }
            break;
        case QMSearchScopeButtonIndexGlobal: {
            [self globalSearch:searchString];
        }
            break;
        default:break;
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    [UIView animateWithDuration:0.12 animations:^{
        
        cell.contentView.transform = CGAffineTransformScale(cell.transform, 1, 1);
    } completion:^(BOOL finished) {
        
        UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ChatViewController"];
        [self.navigationController pushViewController:vc animated:YES];
        
    }];
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [UIView animateWithDuration:0.12 animations:^{
        
        cell.contentView.transform = CGAffineTransformScale(cell.transform, 0.95, 0.95);
        
    }];
    
    return indexPath;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 75;
}

#pragma mark - Search bar

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope  {
    
    if (self.searchRequest ) {
        //Cancel global search request
        [self.searchRequest cancel];
        self.searchRequest = nil;
    }
    
    [self beginSearch:searchBar.text selectedScope:selectedScope];
}

#pragma mark - QMContactCellDelegate

- (void)contactCell:(QMContactCell *)contactCell onPressAddBtn:(id)sender {
    
}

#pragma mark - QMSearchControllerDelegate
#pragma mark Present

- (void)willPresentSearchController:(QMSearchController *)searchController {
    
    self.searchDatasource.addContactHandler = self;
}

- (void)didPresentSearchController:(QMSearchController *)searchController {
    
    [self.tableView setDataSource:nil];
    [self.tableView reloadData];
}

#pragma mark Dissmiss

- (void)willDismissSearchController:(QMSearchController *)searchController {
    
    self.searchDatasource.addContactHandler = nil;
}

- (void)didDismissSearchController:(QMSearchController *)searchController {
    
    [self.tableView setDataSource:self.historyDatasource];
    [self.tableView reloadData];
}

#pragma mark - QMSearchResultsUpdating

- (void)updateSearchResultsForSearchController:(QMSearchController *)searchController {
    
    [self beginSearch:searchController.searchBar.text selectedScope:searchController.searchBar.selectedScopeButtonIndex];
}

#pragma mark - QMAddContactProtocol

- (void)didAddContact:(QBUUser *)contact {
    
   [QM.contactListService addUserToContactListRequest:contact completion:^(BOOL success) {
       
   }];
}

@end
