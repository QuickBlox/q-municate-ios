//
//  QMNewMessageVC.m
//  Q-municate
//
//  Created by Andrey Ivanov on 03.04.15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import "QMNewMessageVC.h"
#import "QMSearchController.h"
#import "QMContactListDatasource.h"

@interface QMNewMessageVC()

<UITableViewDelegate, UISearchBarDelegate,  QMSearchResultsUpdating, QMSearchControllerDelegate>

@property (strong, nonatomic) QMSearchController *searchController;
@property (strong, nonatomic) QMContactListDatasource *searchDatasource;

@end

@implementation QMNewMessageVC

- (void)configureSearchController {
    
    self.definesPresentationContext = YES;
    self.searchController = [[QMSearchController alloc] initWithContentsController:self];
    self.searchController.delegate = self;
    self.searchController.searchResultsDelegate = self;
    self.searchController.searchResultsUpdater = self;
    self.searchController.searchResultsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.searchController.searchResultsTableView.rowHeight = 75;
    self.searchController.searchResultsDataSource = self.searchDatasource;
    self.searchController.searchBar.delegate = self;
    self.searchController.searchBar.placeholder = @"Search";
    self.searchController.searchBar.scopeButtonTitles = @[@"Local", @"Global"];
    
    self.tableView.tableHeaderView = self.searchController.searchBar;
}

@end
