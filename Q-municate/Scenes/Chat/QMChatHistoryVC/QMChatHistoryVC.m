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

NSString *const kQMChatHistoryCellIdentifier = @"QMChatHistoryCell";

@interface QMChatHistoryVC ()

<UITableViewDelegate, QMContactListServiceDelegate>

@property (strong, nonatomic) IBOutlet QMChatHistoryDatasource *historyDatasource;
@property (strong, nonatomic) IBOutlet QMSearchChatHistoryDatasource *searchHistoryDatasource;

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

- (IBAction)pressUserProfileBtn:(id)sender {
    
}

- (void)globalSearch:(NSString *)searchText {
    
    if (searchText.length == 0) {
        
        [self.searchDisplayController.searchResultsTableView reloadData];
    }
    else {
        
        __block NSString *tsearch = [searchText copy];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            if ([self.searchDisplayController.searchBar.text isEqualToString:tsearch]) {
                
                [QBRequest usersWithFullName:searchText
                                        page:[self.searchHistoryDatasource responsePage]
                                successBlock:^(QBResponse *response,
                                               QBGeneralResponsePage *page,
                                               NSArray *users) {
                                    
                                    [self.searchHistoryDatasource addObjects:users];
                                    [self.searchDisplayController.searchResultsTableView reloadData];
                                    
                                } errorBlock:^(QBResponse *response) {
                                    
                                    [self.searchDisplayController.searchResultsTableView reloadData];
                                }];
            }
        });
    }
}

#pragma mark - UISearchDisplayController
#pragma mark UISearchDisplayDelegate

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    
    [self globalSearch:searchString];
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

@end
