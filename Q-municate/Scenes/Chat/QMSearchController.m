//
//  QMSearchController.m
//  Q-municate
//
//  Created by Andrey Ivanov on 26.03.15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import "QMSearchController.h"

@interface QMSearchController()

<UISearchResultsUpdating, UISearchControllerDelegate, UISearchDisplayDelegate>

@property (strong, nonatomic) id searchController;

@end

@implementation QMSearchController

- (instancetype)initWithContentsController:(UIViewController *)viewController {
    
    self = [super init];
    if (self) {
        
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8) {
            
            UITableViewController *searchResultViewController = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
            
            UISearchController *searchController = [[UISearchController alloc] initWithSearchResultsController:searchResultViewController];
            searchController.delegate = self;
            searchController.searchResultsUpdater = self;
            searchController.dimsBackgroundDuringPresentation = NO;
            [searchController.searchBar sizeToFit];
            
            self.searchController = searchController;
        }
        else {
            
            UISearchBar * searchBar = [[UISearchBar alloc] initWithFrame:CGRectZero];
            
            UISearchDisplayController *searchController =
            [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:viewController];
            
            searchController.delegate = self;
            [searchController.searchBar sizeToFit];
            self.searchController = searchController;
        };
    }
    return self;
}

#pragma mark - Getters

- (BOOL)isActive {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8) {
        
       return ((UISearchController *)self.searchController).isActive;
    }
    else {
        
        return ((UISearchDisplayController *)self.searchController).isActive;
    }
}

- (UITableView *)searchResultsTableView {
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8) {
        
        UITableViewController *searchDisplayController = (id)((UISearchController *)self.searchController).searchResultsController;
        return searchDisplayController.tableView;
    }
    else {
        
        return ((UISearchDisplayController *)self.searchController).searchResultsTableView;
    }
}

- (UISearchBar *)searchBar {
    
    if ([[[UIDevice currentDevice] systemVersion] integerValue] >= 8) {
        
         return ((UISearchController *)self.searchController).searchBar;
    }
    else {
        
        return ((UISearchDisplayController *)self.searchController).searchBar;
    }
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
    
    [self.delegate willPresentSearchController:self];
}

- (void)searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller {
    
    [self.delegate didPresentSearchController:self];
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
    
    [self.delegate willDismissSearchController:self];
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller {
    
    [self.delegate didDismissSearchController:self];
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView {}
- (void)searchDisplayController:(UISearchDisplayController *)controller willUnloadSearchResultsTableView:(UITableView *)tableView {}
- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView {}
- (void)searchDisplayController:(UISearchDisplayController *)controller didShowSearchResultsTableView:(UITableView *)tableView {}
- (void)searchDisplayController:(UISearchDisplayController *)controller willHideSearchResultsTableView:(UITableView *)tableView {}
- (void)searchDisplayController:(UISearchDisplayController *)controller didHideSearchResultsTableView:(UITableView *)tableView {}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString  {
    
    [self.searchResultsUpdater updateSearchResultsForSearchController:self];
    
    return NO;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
    
    [self.searchResultsUpdater updateSearchResultsForSearchController:self];
    
    return NO;
}

@end
