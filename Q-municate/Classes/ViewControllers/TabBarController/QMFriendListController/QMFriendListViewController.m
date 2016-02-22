 //
//  QMFriendListController.m
//  Q-municate
//
//  Created by Andrey Ivanov on 7/07/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMFriendListViewController.h"
#import "QMFriendsDetailsController.h"
#import "QMMainTabBarController.h"
#import "QMFriendListCell.h"
#import "QMFriendsListDataSource.h"
#import "QMApi.h"

@interface QMFriendListViewController ()

<UITableViewDelegate, UITableViewDataSource, UISearchDisplayDelegate, QMFriendsListDataSourceDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) QMFriendsListDataSource *dataSource;

@end



@implementation QMFriendListViewController

- (void)dealloc {
    ILog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
}

#define kQMSHOW_SEARCH 0

- (void)viewDidLoad {
    [super viewDidLoad];
    
#if kQMSHOW_SEARCH
    [self.tableView setContentOffset:CGPointMake(0, self.searchDisplayController.searchBar.frame.size.height) animated:NO];
#endif
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.dataSource = [[QMFriendsListDataSource alloc] initWithTableView:self.tableView searchDisplayController:self.searchDisplayController];
    self.dataSource.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshDataSourceAndUnsubscribeFromNotification) name:kUsersLoadingFinishedNotifications object:[QMApi instance]];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 59;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.reuseIdentifier == kQMDontHaveAnyFriendsCellIdentifier) {
        return;
    }
    
    QBUUser *selectedUser = [self.dataSource userAtIndexPath:indexPath];
    QBContactListItem *item = [[QMApi instance] contactItemWithUserID:selectedUser.ID];

    if (item) {
        [self performSegueWithIdentifier:kDetailsSegueIdentifier sender:nil];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - UITableViewDataSource

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self.dataSource tableView:tableView titleForHeaderInSection:section];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.dataSource numberOfSectionsInTableView:tableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataSource tableView:tableView numberOfRowsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self.dataSource tableView:tableView cellForRowAtIndexPath:indexPath];
}

#pragma mark - UISearchDisplayDelegate

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    return [self.dataSource searchDisplayController:controller shouldReloadTableForSearchString:searchString];
}

-(void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller {
    [self.dataSource searchDisplayControllerWillBeginSearch:controller];
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
    [self.dataSource searchDisplayControllerWillEndSearch:controller];
}


#pragma mark - prepareForSegue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:kDetailsSegueIdentifier]) {
        
        NSIndexPath *indexPath = nil;
        if (self.searchDisplayController.isActive) {
            indexPath = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
        } else {
            indexPath = [self.tableView indexPathForSelectedRow];
        }
        QMFriendsDetailsController *vc = segue.destinationViewController;
        vc.selectedUser = [self.dataSource userAtIndexPath:indexPath];
    }
}


#pragma mark - QMFriendsListDataSourceDelegate

- (void)didChangeContactRequestsCount:(NSUInteger)contactRequestsCount
{
    NSUInteger idx = [self.tabBarController.viewControllers indexOfObject:self.navigationController];
    if (idx != NSNotFound) {
        UITabBarItem *item = self.tabBarController.tabBar.items[idx];
        item.badgeValue = contactRequestsCount > 0 ? [NSString stringWithFormat:@"%tu", contactRequestsCount] : nil;
    }
}

#pragma mark - Helpers

- (void)refreshDataSourceAndUnsubscribeFromNotification {
    [self.dataSource reloadDataSource];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kUsersLoadingFinishedNotifications object:[QMApi instance]];
}

@end
