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

#import "QMAddContactCell.h"
#import "QMChatHistoryCell.h"
#import "QMSearchStatusCell.h"

#import "QMSearchController.h"
#import "QMTasks.h"

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
@property (strong, nonatomic) QMChatHistoryDatasource *mainDatasource;
@property (strong, nonatomic) QMSearchChatHistoryDatasource *searchDatasource;

@property (strong, nonatomic) QMNotificationView *notificationView;

@property (weak, nonatomic) QBRequest *searchRequest;
@property (assign, nonatomic) BOOL globalSearchIsCancelled;
@property (strong, nonatomic) QMSearchController *searchController;


@end

@implementation QMChatHistoryVC

#pragma mark - lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mainDatasource = [[QMChatHistoryDatasource alloc] init];
    self.searchDatasource = [[QMSearchChatHistoryDatasource alloc] init];
    self.tableView.dataSource = self.mainDatasource;
    
    [self configureTableView];
    [self configureSearchController];
    [self registerNibs];
    
    [QM.contactListService addDelegate:self];
    
    [QMTasks taskLogin:^(BOOL success) {
        
    }];
}

- (void)stupNotificationView {
    
    self.notificationView = [QMNotificationView showInViewController:self];
    self.notificationView.tintColor = [UIColor colorWithWhite:0.800 alpha:0.380];
    [self.notificationView setVisible:YES animated:YES completion:^{
        
    }];
}

#pragma mark - QMContactListServiceDelegate

- (void)contactListServiceDidLoadCache {
    
    NSArray *usersFormCache = [QM.contactListService.usersMemoryStorage unsorterdUsersFromMemoryStorage];
    [self.mainDatasource.collection addObjectsFromArray:usersFormCache];
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

- (void)registerNibs {
    
    [QMChatHistoryCell registerForReuseInTableView:self.tableView];
    [QMChatHistoryCell registerForReuseInTableView:self.searchController.searchResultsTableView];
    [QMAddContactCell registerForReuseInTableView:self.searchController.searchResultsTableView];
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
    [self.searchDatasource.collection removeAllObjects];
    self.searchDatasource.searchText = nil;
    [self.searchController.searchResultsTableView reloadData];
}

#pragma mark - Search

- (void)globalSearch:(NSString *)searchText {
    
    self.globalSearchIsCancelled = NO;
    
    if (searchText.length == 0) {
        //Clear datasource
        [self.searchDatasource.collection removeAllObjects];
        [self.searchController.searchResultsTableView reloadData];
    }
    else {

        int64_t keyboadTapTimeInterval = (int64_t)(kQMKeyboardTapTimeInterval * NSEC_PER_SEC);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, keyboadTapTimeInterval), dispatch_get_main_queue(), ^{
            if ([self.searchController.searchBar.text isEqualToString:searchText]) {
                
                if (self.globalSearchIsCancelled) {
                    
                    self.globalSearchIsCancelled = NO;
                    return;
                }
                
                [self beginSearchWithSearchText:searchText nextPage:NO];
                [self.searchController.searchResultsTableView reloadData];
            }
        });
    }
}

- (void)beginSearchWithSearchText:(NSString *)searchText nextPage:(BOOL)nextPage {
    
    if (!nextPage) {
        [self.searchDatasource resetPage];
    }
    
    QBGeneralResponsePage *currentPage = [self.searchDatasource nextPage];
    
    if (!currentPage) {
        return;
    }
    __weak __typeof(self)weakSelf = self;
    
    self.searchRequest =
    [QBRequest usersWithFullName:searchText
                            page:currentPage
                    successBlock:^(QBResponse *response,
                                   QBGeneralResponsePage *page,
                                   NSArray *users)
     {
         [weakSelf.searchDatasource.collection addObjectsFromArray:users];
         [weakSelf.searchDatasource setSearchText:searchText];
         [weakSelf.searchDatasource updateCurrentPageWithResponcePage:page];
         [weakSelf.searchController.searchResultsTableView reloadData];
         weakSelf.searchRequest = nil;
         
     } errorBlock:^(QBResponse *response) {
         
         if (response.status == QBResponseStatusCodeCancelled) {
             
             NSLog(@"Global search is cancelled");
         } else if (response.status == QBResponseStatusCodeNotFound) {
             
             NSLog(@"Not found");
         }
     }];
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
    
    [UIView animateWithDuration:0.2 animations:^{
        
        cell.contentView.transform = CGAffineTransformScale(cell.transform, 1, 1);
        
    } completion:^(BOOL finished) {
        
        UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ChatViewController"];
        [self.navigationController pushViewController:vc animated:YES];
        
    }];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView == self.searchController.searchResultsTableView) {
        
        if (indexPath.row == (int) self.searchDatasource.collection.count && self.searchDatasource.collection.count != 0 ) {
            
            [self beginSearchWithSearchText:self.searchController.searchBar.text nextPage:YES];
        }
    }
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.contentView.transform = CGAffineTransformScale(cell.transform, 0.95, 0.95);
    
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

#pragma mark - QMSearchControllerDelegate
#pragma mark Present

- (void)willPresentSearchController:(QMSearchController *)searchController {
    
    self.searchDatasource.addContactHandler = self;
}

- (void)didPresentSearchController:(QMSearchController *)searchController {
    
    self.tableView.dataSource = nil;
    [self.tableView reloadData];
}

#pragma mark Dissmiss

- (void)willDismissSearchController:(QMSearchController *)searchController {
    
    self.searchDatasource.addContactHandler = nil;
}

- (void)didDismissSearchController:(QMSearchController *)searchController {

    self.tableView.dataSource = self.mainDatasource;
    [self.tableView reloadData];
}

#pragma mark - QMSearchResultsUpdating

- (void)updateSearchResultsForSearchController:(QMSearchController *)searchController {
    
    [self beginSearch:searchController.searchBar.text
        selectedScope:searchController.searchBar.selectedScopeButtonIndex];
}

#pragma mark - QMAddContactProtocol

- (void)didAddContact:(QBUUser *)contact {
   
    //Send add contact request and create p2p chat 
   [QM.contactListService addUserToContactListRequest:contact
                                           completion:^(BOOL success)
    {
       if (success) {
           
           [QM.chatService createPrivateChatDialogIfNeededWithOpponent:contact
                                                            completion:^(QBResponse *response,
                                                                         QBChatDialog *createdDialog) {
                                                                
                                                            }];
       }
   }];
}

@end
