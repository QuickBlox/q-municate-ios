//
//  QMChatHistoryVC.m
//  Q-municate
//
//  Created by Andrey Ivanov on 11.03.15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import "QMChatHistoryVC.h"
#import "QMChatHistoryCell.h"
#import "QMServicesManager.h"
#import "QMChatHistoryDatasource.h"
#import "QMSearchChatHistoryDatasource.h"
#import "QMNotificationView.h"

NSString *const kQMChatHistoryCellIdentifier = @"QMChatHistoryCell";

typedef NS_ENUM(NSUInteger, QMSearchScopeButtonIndex) {
    
    QMSearchScopeButtonIndexLocal,
    QMSearchScopeButtonIndexGlobal
};

@interface QMChatHistoryVC ()

<UITableViewDelegate, QMContactListServiceDelegate, UISearchBarDelegate, UISearchDisplayDelegate>

@property (strong, nonatomic) IBOutlet QMChatHistoryDatasource *historyDatasource;
@property (strong, nonatomic) IBOutlet QMSearchChatHistoryDatasource *searchHistoryDatasource;
@property (weak, nonatomic) QBRequest *searchRequest;
@property (strong, nonatomic) QMNotificationView *notificationView;

@end

@implementation QMChatHistoryVC

#pragma mark - lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureTableView];
    [self configureSearchDisplayController];
    [self registerNibs];
    
    [QM.contactListService addDelegate:self];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.notificationView = [QMNotificationView showInViewController:self];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.notificationView setTintColor:[UIColor colorWithRed:1.000 green:0.557 blue:0.271 alpha:0.730]];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.notificationView setTintColor:[UIColor colorWithRed:1.000 green:0.557 blue:0.271 alpha:0.730]];
    });
    
    self.tableView.contentInset = UIEdgeInsetsMake(30, 0, 0, 0);
}

#pragma mark - QMContactListServiceDelegate

- (void)contactListServiceDidLoadCache {
    
}

#pragma mark -

- (void)configureTableView {
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    //Enable auto layout for dynamic cell
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 75.0;
    // Hide serach bar
    self.tableView.contentOffset = CGPointMake(0, self.searchDisplayController.searchBar.frame.size.height);
    //Add refresh control
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    

}

- (void)configureSearchDisplayController {
    
    self.searchDisplayController.searchResultsTableView.rowHeight = UITableViewAutomaticDimension;
    self.searchDisplayController.searchResultsTableView.estimatedRowHeight = 75.0;
}

- (void)registerNibs {
    
    //Register nibs
    UINib *chatHistoryCellNib = [UINib nibWithNibName:@"QMChatHistoryCell" bundle:NSBundle.mainBundle];
    [self.tableView registerNib:chatHistoryCellNib forCellReuseIdentifier:kQMChatHistoryCellIdentifier];
    [self.searchDisplayController.searchResultsTableView registerNib:chatHistoryCellNib forCellReuseIdentifier:kQMChatHistoryCellIdentifier];
}

#pragma mark - Actions
#pragma mark Refresh control

- (void)refresh:(UIRefreshControl *)sender {
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.refreshControl endRefreshing];
    });
}

#pragma mark Navigation bar actions

- (IBAction)pressNewNavItem:(id)sender {
    
}


- (void)localSearch:(NSString *)searchText {
    
    [self.searchHistoryDatasource setObjects:nil];
    self.searchHistoryDatasource.searchText = nil;
    [self.searchDisplayController.searchResultsTableView reloadData];
}

#pragma mark - Search

- (void)globalSearch:(NSString *)searchText {
    
    if (searchText.length == 0) {
        
        [self.searchDisplayController.searchResultsTableView reloadData];
    }
    else {
        
        __block NSString *tsearch = [searchText copy];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            if ([self.searchDisplayController.searchBar.text isEqualToString:tsearch]) {
                
                __weak __typeof(self)weakSelf = self;
                self.searchRequest =
                [QBRequest usersWithFullName:searchText
                                        page:[self.searchHistoryDatasource responsePage]
                                successBlock:^(QBResponse *response,
                                               QBGeneralResponsePage *page,
                                               NSArray *users)
                 {
                     
                     [weakSelf.searchHistoryDatasource setObjects:users];
                     weakSelf.searchHistoryDatasource.searchText = searchText;
                     [weakSelf.searchDisplayController.searchResultsTableView reloadData];
                     
                 } errorBlock:^(QBResponse *response) {
                     
                     [weakSelf.searchDisplayController.searchResultsTableView reloadData];
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

#pragma mark - Search bar

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope  {
    
    if (self.searchRequest) {
        
        [self.searchRequest cancel];
    }
    
    [self beginSearch:searchBar.text selectedScope:selectedScope];
}

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller {
    [self.notificationView setVisible:NO animated:NO completion:nil];
    
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller {
    [self.notificationView setVisible:YES animated:NO completion:nil];
}

@end
