//
//  QMFriendListController.m
//  Q-municate
//
//  Created by Ivanov Andrey on 7/07/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMFriendListViewController.h"
#import "QMFriendsDetailsController.h"
#import "QMFriendListCell.h"
#import "QMFriendsListDataSource.h"
#import "QMApi.h"

@interface QMFriendListViewController ()

<UISearchBarDelegate, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *searchBarTopConstraint;

@property (nonatomic, strong) QMFriendsListDataSource *dataSource;

@end

@implementation QMFriendListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.dataSource = [[QMFriendsListDataSource alloc] initWithTableView:self.tableView];
    self.tableView.delegate = self;
    
    self.searchBar.delegate = self;
    [self showSearchBar:NO animated:NO];
}

#pragma mark - Actions

- (IBAction)globalSearch:(id)sender {
    
    [self.dataSource globalSearch];
}

- (IBAction)searchUsers:(UIButton *)sender {
    
    self.dataSource.searchActive ^= 1;
    [self showSearchBar:self.dataSource.searchActive animated:YES];
}

#pragma mark - Show/Hide UISearchBar

- (void)showSearchBar:(BOOL)isShow animated:(BOOL)animated {

    self.searchBarTopConstraint.constant -= self.searchBar.frame.size.height * (isShow ?  -1 : 1);

    if (!isShow) {
        self.dataSource.searchText = self.searchBar.text = nil;
    }
    
    void(^show)(void) = ^() {
        [self.view layoutIfNeeded];
    };
    
    animated ? [UIView animateWithDuration:0.3 animations:show] : show();
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    self.dataSource.searchText = searchText;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    [self performSegueWithIdentifier:kDetailsSegueIdentifier sender:nil];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:kDetailsSegueIdentifier]) {
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSArray *users = [self.dataSource usersAtSections:indexPath.section];
        QBUUser *selectedUser = users[indexPath.row];
        
        QMFriendsDetailsController *vc = segue.destinationViewController;
        vc.selectedUser = selectedUser;
    }
}

@end
