//
//  QMSearchController.m
//  Q-municate
//
//  Created by Andrey Ivanov on 26.03.15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import "QMSearchController.h"

#ifdef __IPHONE_8_0
#define SEARCH_PROTOCOL UISearchResultsUpdating, UISearchControllerDelegate, UISearchDisplayDelegate
#else
#define SEARCH_PROTOCOL UISearchDisplayDelegate
#endif

@interface QMSearchController() <SEARCH_PROTOCOL>

#ifdef __IPHONE_8_0
@property (strong, nonatomic) UISearchController *searchController;
#else
@property (strong, nonatomic) UISearchDisplayController *searchController;
#endif

@end

@implementation QMSearchController

- (instancetype)initWithContentsController:(UIViewController *)viewController {
    
    self = [super init];
    if (self) {
        
        [self configureSearchController];
    }
    return self;
}

- (void)configureSearchController {

#ifdef __IPHONE_8_0
    
    UITableViewController *searchResultViewController = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
    
    UISearchController *searchController = [[UISearchController alloc] initWithSearchResultsController:searchResultViewController];
    searchController.delegate = self;
    searchController.searchResultsUpdater = self;
    searchController.dimsBackgroundDuringPresentation = NO;
    
    self.searchController = searchController;
    [self.searchController.searchBar sizeToFit];
    
#else // iOS < 8
    
    UISearchBar * searchBar = [[UISearchBar alloc] initWithFrame:CGRectZero];
    
    UISearchDisplayController *searchController =
    [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
    
    searchController.delegate = self;
    searchController.searchResultsDataSource = self;
    searchController.searchResultsDelegate = self;
    
    self.searchController = searchController;

#endif
}

#pragma mark - Getters

- (UITableView *)searchResultsTableView {
    
#ifdef __IPHONE_8_0
    UITableViewController *searchDisplayController = (id)self.searchController.searchResultsController;
    return searchDisplayController.tableView;
#else
    return self.searchDisplayController.searchResultsTableView;
#endif
}

- (UISearchBar *)searchBar {
    
#ifdef __IPHONE_8_0
    return self.searchController.searchBar;
#else
    return self.searchDisplayController.searchBar;
#endif
}

- (void)reloadSearchResult {
    
    [self.searchResultsTableView reloadData];
}

#pragma mark - Setters

- (void)setSearchResultsDelegate:(id<UITableViewDelegate>)searchResultsDelegate {

    if (_searchResultsDelegate != searchResultsDelegate) {
        
        _searchResultsDelegate = searchResultsDelegate;
        self.searchResultsTableView.delegate = _searchResultsDelegate;
    }
}

- (void)setSearchResultsDataSource:(id<UITableViewDataSource>)searchResultsDataSource {
    
    if (_searchResultsDataSource != searchResultsDataSource) {
        
        _searchResultsDataSource = searchResultsDataSource;
        self.searchResultsTableView.dataSource = _searchResultsDataSource;
    }
}

#pragma mark -  UISearchControllerDelegate

- (void)willPresentSearchController:(UISearchController *)searchController {
    [self.delegate willPresentSearchController:self];
}

- (void)didPresentSearchController:(UISearchController *)searchController {
    [self.delegate didPresentSearchController:self];
}

- (void)willDismissSearchController:(UISearchController *)searchController {
    [self.delegate willDismissSearchController:self];
}

- (void)didDismissSearchController:(UISearchController *)searchController {
    [self.delegate didDismissSearchController:self];
}

#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    
    [self.searchResultsUpdater updateSearchResultsForSearchController:self];
}

#pragma mark - UISearchDisplayDelegate
// when we start/end showing the search UI
- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller {
    
}

- (void)searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller {
    
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
    
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller {
    
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView {
    
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willUnloadSearchResultsTableView:(UITableView *)tableView {
    
}
// called when table is shown/hidden
- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView {
    
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didShowSearchResultsTableView:(UITableView *)tableView {
    
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willHideSearchResultsTableView:(UITableView *)tableView {
    
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didHideSearchResultsTableView:(UITableView *)tableView {
    
}
// return YES to reload table. called when search string/option changes. convenience methods on top UISearchBar delegate methods
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString  {
    
    return NO;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
    
    return NO;
}

@end
