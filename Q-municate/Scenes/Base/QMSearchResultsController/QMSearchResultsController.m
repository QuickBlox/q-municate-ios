//
//  QMSearchResultsController.m
//  Q-municate
//
//  Created by Injoit on 5/17/16.
//  Copyright © 2016 QuickBlox. All rights reserved.
//

#import "QMSearchResultsController.h"
#import "QMTableViewDataSource.h"

@interface QMSearchResultsController ()

@end

@implementation QMSearchResultsController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Hide empty separators
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)performSearch:(NSString *)searchText {
    
    [self.searchDataSource.searchDataProvider performSearch:searchText];
}

//MARK: - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return [self.searchDataSource heightForRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    id obj = [self.searchDataSource objectAtIndexPath:indexPath];
    [self.delegate searchResultsController:self didSelectObject:obj];
}

//MARK: - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    [self.delegate searchResultsController:self willBeginScrollResults:scrollView];
}

//MARK: - QMSearchProtocol

- (QMTableViewSearchDataSource *)searchDataSource {
    
    return (id)self.tableView.dataSource;
}

//MARK: - QMSearchDataProviderDelegate

- (void)searchDataProviderDidFinishDataFetching:(QMSearchDataProvider *)searchDataProvider {
    
    if ([self.tableView.dataSource isKindOfClass:[QMTableViewSearchDataSource class]]
        && self.searchDataSource.searchDataProvider != searchDataProvider) {
        // search data provider is not visible right now
        // no need to reload current table view
        return;
    }
    
    [self.tableView reloadData];
}

- (void)searchDataProvider:(QMSearchDataProvider *)searchDataProvider didUpdateData:(NSArray *)data {
    
    if ([self.tableView.dataSource isKindOfClass:[QMTableViewSearchDataSource class]]
        && self.searchDataSource.searchDataProvider != searchDataProvider) {
        // search data provider is not visible right now
        // no need to reload current table view
        return;
    }
    
    [self.tableView reloadData];
}

@end
