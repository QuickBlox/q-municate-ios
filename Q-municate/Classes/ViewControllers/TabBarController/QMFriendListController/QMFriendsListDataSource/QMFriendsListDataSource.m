//
//  QMFriendsListDataSource.m
//  Q-municate
//
//  Created by Andrey Ivanov on 4/3/14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMFriendsListDataSource.h"
#import "QMUsersService.h"
#import "QMFriendListCell.h"
#import "QMContactRequestCell.h"
#import "QMApi.h"
#import "QMUsersService.h"
#import "SVProgressHud.h"
#import "QMChatReceiver.h"
#import "REAlertView.h"



@interface QMFriendsListDataSource()


@property (strong, nonatomic) NSArray *searchResult;
@property (strong, nonatomic) NSArray *friendList;
@property (strong, nonatomic) NSArray *contactRequests;

@property (weak, nonatomic) UITableView *tableView;
@property (weak, nonatomic) UISearchDisplayController *searchDisplayController;
@property (strong, nonatomic) NSObject<Cancelable> *searchOperation;

@property (strong, nonatomic) id tUser;

@property (assign, nonatomic) BOOL searchIsActive;

@end

@implementation QMFriendsListDataSource

@synthesize friendList = _friendList;

- (void)dealloc {
    ILog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
    [[QMChatReceiver instance] unsubscribeForTarget:self];
}

- (instancetype)initWithTableView:(UITableView *)tableView searchDisplayController:(UISearchDisplayController *)searchDisplayController {
    
    self = [super init];
    if (self) {
        
        self.tableView = tableView;
        self.tableView.dataSource = self;
        self.searchResult = [NSArray array];
        
        self.searchDisplayController = searchDisplayController;
        __weak __typeof(self)weakSelf = self;
        
        void (^reloadDatasource)(void) = ^(void) {
            
            if (weakSelf.searchOperation) {
                return;
            }
            
            if (weakSelf.searchIsActive) {
                
                CGPoint point = weakSelf.searchDisplayController.searchResultsTableView.contentOffset;
                
                weakSelf.friendList = [QMApi instance].friends;
                [weakSelf.searchDisplayController.searchResultsTableView reloadData];
                NSUInteger idx = [weakSelf.friendList indexOfObject:weakSelf.tUser];
                NSUInteger idx2 = [weakSelf.searchResult indexOfObject:weakSelf.tUser];
               
                if (idx != NSNotFound && idx2 != NSNotFound) {
                    
                    point .y += 59;
                    weakSelf.searchDisplayController.searchResultsTableView.contentOffset = point;
                    
                    weakSelf.tUser = nil;
                    [SVProgressHUD dismiss];
                }
                
            }
            else {
                [weakSelf reloadDatasource];
            }
        };
        
        [[QMChatReceiver instance] contactRequestUsersListChangedWithTarget:self block:^{
            weakSelf.contactRequests = [QMApi instance].contactRequestUsers;
            
            [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 2)] withRowAnimation:UITableViewRowAnimationFade];
        }];
        
        [[QMChatReceiver instance] usersHistoryUpdatedWithTarget:self block:reloadDatasource];
        [[QMChatReceiver instance] chatContactListUpdatedWithTarget:self block:reloadDatasource];
        
        UINib *friendsCellNib = [UINib nibWithNibName:@"QMFriendListCell" bundle:nil];
        UINib *contactRequestCellNib = [UINib nibWithNibName:@"QMContactRequestCell" bundle:nil];
        UINib *noResultsCellNib = [UINib nibWithNibName:@"QMNoResultsCell" bundle:nil];
        
        [searchDisplayController.searchResultsTableView registerNib:friendsCellNib forCellReuseIdentifier:kQMFriendsListCellIdentifier];
        [searchDisplayController.searchResultsTableView registerNib:contactRequestCellNib forCellReuseIdentifier:kQMContactRequestCellIdentifier];
        [searchDisplayController.searchResultsTableView registerNib:noResultsCellNib forCellReuseIdentifier:kQMDontHaveAnyFriendsCellIdentifier];
    }
    
    return self;
}

- (void)setFriendList:(NSArray *)friendList {
    _friendList = [QMUsersUtils sortUsersByFullname:friendList];
}

- (NSArray *)friendList {
    
    if (self.searchIsActive && self.searchDisplayController.searchBar.text.length > 0) {
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.fullName CONTAINS[cd] %@", self.searchDisplayController.searchBar.text];
        NSArray *filtered = [_friendList filteredArrayUsingPredicate:predicate];
        
        return filtered;
    }
    return _friendList;
}

- (void)reloadDatasource {
    
    self.friendList = [QMApi instance].friends;
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)globalSearch:(NSString *)searchText {
    
    if (searchText.length == 0) {
        self.searchResult = @[];
        [self.searchDisplayController.searchResultsTableView reloadData];
        return;
    }
    
    __weak __typeof(self)weakSelf = self;
    QBUUserPagedResultBlock userPagedBlock = ^(QBUUserPagedResult *pagedResult) {
        
        NSArray *users = [QMUsersUtils sortUsersByFullname:pagedResult.users];
        //Remove current user from search result
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.ID != %d", [QMApi instance].currentUser.ID];
        weakSelf.searchResult = [users filteredArrayUsingPredicate:predicate];
        [weakSelf.searchDisplayController.searchResultsTableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationFade];
        weakSelf.searchOperation = nil;
        [SVProgressHUD dismiss];
    };
    
    [self.searchDisplayController.searchResultsTableView reloadData];
    
    __block NSString *tsearch = [searchText copy];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        if ([weakSelf.searchDisplayController.searchBar.text isEqualToString:tsearch]) {
            
            if (weakSelf.searchOperation) {
                [weakSelf.searchOperation cancel];
                weakSelf.searchOperation = nil;
            }
            
            PagedRequest *request = [[PagedRequest alloc] init];
            request.page = 1;
            request.perPage = 100;
            
            
            [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
            weakSelf.searchOperation = [[QMApi instance].usersService retrieveUsersWithFullName:searchText pagedRequest:request completion:userPagedBlock];
        }
    });
}

#pragma mark - UITableViewDataSource

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    NSArray *users = [self usersAtSections:section];
    
    if (section == 0) {
        return (!self.searchIsActive && users.count > 0) ? NSLocalizedString(@"QM_STR_REQUESTS", nil) : nil;
    } else if (section == 1) {
        return (users.count > 0) ? NSLocalizedString(@"QM_STR_FRIENDS", nil) : nil;
    }
    return (self.searchIsActive) ? NSLocalizedString(@"QM_STR_ALL_USERS", nil) : nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if (self.searchIsActive) {
        return 3;
    }
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *users = [self usersAtSections:section];
    
    if (section == 0) {
        return (!self.searchIsActive && [users count] > 0) ? users.count : 0;
    } else if (section == 1) {
        if (self.searchIsActive) {
            return ([users count] > 0) ? users.count : 0;
        }
        else if ([self.contactRequests count] > 0) {
            return ([users count] > 0) ? users.count : 0;
        }
        return ([users count] > 0) ? users.count : 1;
    }
    return (self.searchIsActive && users.count > 0) ? users.count : 0;
}

- (NSArray *)usersAtSections:(NSInteger)section
{
    if (section == 0 ) {
        return self.contactRequests;
    } else if (section == 1) {
        return self.friendList;
    }
    return self.searchResult;
}

- (QBUUser *)userAtIndexPath:(NSIndexPath *)indexPath {
    
    NSArray *users = [self usersAtSections:indexPath.section];
    QBUUser *user = users[indexPath.row];
    
    return user;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSArray *users = [self usersAtSections:indexPath.section];
    
    if (!self.searchIsActive) {
        if (users.count == 0) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kQMDontHaveAnyFriendsCellIdentifier];
            return cell;
        }
    }
    QMTableViewCell *cell = nil;
    if (indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:kQMContactRequestCellIdentifier];
        ((QMContactRequestCell *)cell).delegate = self;
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:kQMFriendsListCellIdentifier];
        ((QMFriendListCell *)cell).delegate = self;
    }
    QBUUser *user = users[indexPath.row];
    
    QBContactListItem *item = [[QMApi instance] contactItemWithUserID:user.ID];
    cell.contactlistItem = item;
    cell.userData = user;
    
    if(self.searchIsActive && [cell isKindOfClass:QMFriendListCell.class]) {
        ((QMFriendListCell *)cell).searchText = self.searchDisplayController.searchBar.text;
    }
    
    return cell;
}


#pragma mark - QMUsersListCellDelegate

- (void)usersListCell:(QMFriendListCell *)cell pressAddBtn:(UIButton *)sender {
    
    NSIndexPath *indexPath = [self.searchDisplayController.searchResultsTableView indexPathForCell:cell];
    NSArray *datasource = [self usersAtSections:indexPath.section];
    QBUUser *user = datasource[indexPath.row];
    
    __weak __typeof(self)weakSelf = self;
    [[QMApi instance] addUserToContactListRequest:user completion:^(BOOL success) {
        if (success) {
            weakSelf.tUser = user;
            [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
        }
    }];
}

- (void)usersListCell:(QMTableViewCell *)cell requestWasAccepted:(BOOL)accepted
{
    QBUUser *user = cell.userData;    
    __weak __typeof(self)weakSelf = self;

    if (accepted) {
        [[QMApi instance] confirmAddContactRequest:user.ID completion:^(BOOL success) {
            weakSelf.contactRequests = [QMApi instance].contactRequestUsers;
            [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationTop];
            
        }];
    } else {
        
        [REAlertView presentAlertViewWithConfiguration:^(REAlertView *alertView) {
            alertView.title = @"Are you sure?";
            [alertView addButtonWithTitle:@"Cancel" andActionBlock:^{}];
            [alertView addButtonWithTitle:@"OK" andActionBlock:^{
                //
                [[QMApi instance] rejectAddContactRequest:user.ID completion:^(BOOL success) {
                    weakSelf.contactRequests = [QMApi instance].contactRequestUsers;
                    NSIndexPath *indexPath = [weakSelf.tableView indexPathForCell:cell];
                    [weakSelf.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
                    
                }];
            }];
        }];
    }
}


#pragma mark - UISearchDisplayController

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    if (!self.searchIsActive) {
        self.searchIsActive = YES;
    }
    [self globalSearch:searchString];
    return NO;
}

-(void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
//    [controller.searchResultsTableView reloadData];
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller
{
    if (self.searchIsActive) {
        self.searchIsActive = NO;
    }
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
}

@end
