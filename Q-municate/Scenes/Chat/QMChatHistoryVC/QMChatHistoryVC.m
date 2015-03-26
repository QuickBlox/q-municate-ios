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

const NSTimeInterval kQMKeyboardTapTimeInterval = 1.f;

typedef NS_ENUM(NSUInteger, QMSearchScopeButtonIndex) {
    
    QMSearchScopeButtonIndexLocal,
    QMSearchScopeButtonIndexGlobal
};

@interface QMChatHistoryVC ()

<UITableViewDelegate, QMContactListServiceDelegate, UISearchBarDelegate, UISearchDisplayDelegate, QMContactCellDelegate>

@property (strong, nonatomic) IBOutlet QMChatHistoryDatasource *historyDatasource;
@property (strong, nonatomic) IBOutlet QMSearchChatHistoryDatasource *searchHistoryDatasource;
@property (strong, nonatomic) QMNotificationView *notificationView;

@property (weak, nonatomic) QBRequest *searchRequest;
@property (assign, nonatomic) BOOL globalSearchIsCancelled;

@end

@implementation QMChatHistoryVC

#pragma mark - lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self registerNibs];
    [self configureTableView];
    [self configureSearchDisplayController];
    self.definesPresentationContext = YES;
    [QM.contactListService addDelegate:self];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
//    self.notificationView = [QMNotificationView showInViewController:self];
//    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self.notificationView setTintColor:[UIColor colorWithRed:1.000 green:0.557 blue:0.271 alpha:0.730]];
//    });
//    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self.notificationView setTintColor:[UIColor colorWithRed:1.000 green:0.557 blue:0.271 alpha:0.730]];
//    });
//    
//    self.tableView.contentInset = UIEdgeInsetsMake(44+20+30, 0, 0, 0);
}

#pragma mark - QMContactListServiceDelegate

- (void)contactListServiceDidLoadCache {
    
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

- (void)configureSearchDisplayController {
    
    self.searchDisplayController.searchResultsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.searchDisplayController.searchResultsTableView.rowHeight = 75;
}

- (void)registerNibs {
    
    //Register cell
    [QMChatHistoryCell registerForReuseInTableView:self.tableView];
    [QMChatHistoryCell registerForReuseInTableView:self.searchDisplayController.searchResultsTableView];
    [QMContactCell registerForReuseInTableView:self.searchDisplayController.searchResultsTableView];
    [QMSearchStatusCell registerForReuseInTableView:self.searchDisplayController.searchResultsTableView];
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
    [self.searchHistoryDatasource setObjects:nil];
    self.searchHistoryDatasource.searchText = nil;
    [self.searchDisplayController.searchResultsTableView reloadData];
}

#pragma mark - Search

- (void)globalSearch:(NSString *)searchText {
    
    self.globalSearchIsCancelled = NO;
    
    if (searchText.length == 0) {
        //Clear datasource
        [self.searchHistoryDatasource setObjects:@[]];
        [self.searchDisplayController.searchResultsTableView reloadData];
    }
    else {
        
        self.searchHistoryDatasource.loading = YES;
        [self.searchDisplayController.searchResultsTableView reloadData];
        
        int64_t keyboadTapTimeInterval = (int64_t)(kQMKeyboardTapTimeInterval * NSEC_PER_SEC);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, keyboadTapTimeInterval), dispatch_get_main_queue(), ^{
            
            if ([self.searchDisplayController.searchBar.text isEqualToString:searchText]) {
                
                if (self.globalSearchIsCancelled) {
                    
                    self.globalSearchIsCancelled = NO;
                    return;
                }
                
                __weak __typeof(self)weakSelf = self;
                self.searchRequest =
                [QBRequest usersWithFullName:searchText
                                        page:[self.searchHistoryDatasource responsePage]
                                successBlock:^(QBResponse *response,
                                               QBGeneralResponsePage *page,
                                               NSArray *users)
                 {
                     [weakSelf.searchHistoryDatasource setObjects:users];
                     [weakSelf.searchHistoryDatasource setSearchText:searchText];
                     weakSelf.searchHistoryDatasource.loading = NO;
                     [weakSelf.searchDisplayController.searchResultsTableView reloadData];
                     weakSelf.searchRequest = nil;
                     
                 } errorBlock:^(QBResponse *response) {
                     
                     weakSelf.searchHistoryDatasource.loading = NO;
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
            
        case QMSearchScopeButtonIndexLocal:
            [self localSearch:searchString]; break;
        case QMSearchScopeButtonIndexGlobal:
            [self globalSearch:searchString]; break;
        default:break;
    }
}

#pragma mark - UISearchDisplayDelegate

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    
    [self beginSearch:searchString selectedScope:controller.searchBar.selectedScopeButtonIndex];
    
    return NO;
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didShowSearchResultsTableView:(UITableView *)tableView {
    
    [self.tableView setDataSource:nil];
    [self.tableView reloadData];
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didHideSearchResultsTableView:(UITableView *)tableView {
    
    [self.tableView setDataSource:self.historyDatasource];
    [self.tableView reloadData];
}

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller {

    [self.notificationView setVisible:NO animated:NO completion:nil];
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
    
    [self.notificationView setVisible:YES animated:NO completion:nil];
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

@end
