//
//  QMSearchResultsController.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 5/17/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMSearchResultsController.h"

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

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)__unused tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return [self.searchDataSource heightForRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    id obj = [self.searchDataSource objectAtIndexPath:indexPath];
    [self.delegate searchResultsController:self didSelectObject:obj];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    [self.delegate searchResultsController:self willBeginScrollResults:scrollView];
}

#pragma mark - QMSearchProtocol

- (QMSearchDataSource *)searchDataSource {
    
    return (id)self.tableView.dataSource;
}

#pragma mark - QMSearchDataProviderDelegate

- (void)searchDataProviderDidFinishDataFetching:(QMSearchDataProvider *)searchDataProvider {
    
    if ([self.tableView.dataSource isKindOfClass:[QMSearchDataSource class]]
        && self.searchDataSource.searchDataProvider != searchDataProvider) {
        // search data provider is not visible right now
        // no need to reload current table view
        return;
    }
    
    [self.tableView reloadData];
}

- (void)searchDataProvider:(QMSearchDataProvider *)__unused searchDataProvider didUpdateData:(NSArray *)__unused data {
    
    if ([self.tableView.dataSource isKindOfClass:[QMSearchDataSource class]]
        && self.searchDataSource.searchDataProvider != searchDataProvider) {
        // search data provider is not visible right now
        // no need to reload current table view
        return;
    }
    
    [self.tableView reloadData];
}

@end
