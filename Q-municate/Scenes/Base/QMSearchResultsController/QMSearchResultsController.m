//
//  QMSearchResultsController.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 2/29/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMSearchResultsController.h"
#import "QMTableViewDataSource.h"
#import "QMLocalSearchDataSource.h"
#import "QMCore.h"
#import "QMLocalSearchDataProvider.h"

#import "QMDialogCell.h"
#import "QMContactCell.h"

static const NSTimeInterval kQMGlobalSearchTimeInterval = 0.6f;
static const NSUInteger kQMGlobalSearchCharsMin = 3;
static const NSUInteger kQMUsersPageLimit       = 50;

@interface QMSearchResultsController ()

<
UITableViewDelegate
>

@end

@implementation QMSearchResultsController

- (instancetype)init {
    
    if (self = [super init]) {
        
        [self registerNibs];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    
    // Hide empty separators
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

#pragma mark Search methods

- (void)performSearch:(NSString *)searchText {
    
    [self.searchDataSource.searchDataProvider performSearch:searchText];
}

#pragma mark - QMSearchDataProviderDelegate

- (void)searchDataProviderDidFinishDataFetching:(QMSearchDataProvider *)searchDataProvider {
    
    [self.tableView reloadData];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return [self.searchDataSource heightForRowAtIndexPath:indexPath];
}

#pragma mark - Register nibs

- (void)registerNibs {
    
    [QMDialogCell registerForReuseInTableView:self.tableView];
    [QMContactCell registerForReuseInTableView:self.tableView];
}

#pragma mark - QMSearchProtocol

- (QMSearchDataSource *)searchDataSource {
    
    return (id)self.tableView.dataSource;
}

@end
