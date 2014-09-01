//
//  QMSearchDataSource.m
//  Q-municate
//
//  Created by Igor Alefirenko on 01/09/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMSearchDataSource.h"
#import "QMFriendListCell.h"
#import "QMFriendsListDataSource.h"
#import "QMApi.h"


@implementation QMSearchDataSource

#pragma mark - Table View Data Source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return self.friends.count > 0 ? NSLocalizedString(@"QM_STR_FRIENDS", nil) : nil;
    }
    return self.otherUsers.count > 0 ? NSLocalizedString(@"QM_STR_ALL_USERS", nil) : nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return [self.friends count];
    }
    return [self.otherUsers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ILog(@"IndexPath section: %d, row: %d", indexPath.section, indexPath.row);
    QMFriendListCell *cell = [tableView dequeueReusableCellWithIdentifier:kQMFriendsListCellIdentifier];
    
    QBUUser *user = [self userAtIndexPath:indexPath];
    
    QBContactListItem *item = [[QMApi instance] contactItemWithUserID:user.ID];
    cell.contactlistItem = item;
    cell.userData = user;
    cell.searchText = self.searchString;
    
    cell.delegate = self.friendsListDataSource;

    return cell;
}

- (QBUUser *)userAtIndexPath:(NSIndexPath *)indexPath {
    
    NSArray *users = [self usersAtSections:indexPath.section];
    QBUUser *user = users[indexPath.row];
    
    return user;
}

- (NSArray *)usersAtSections:(NSInteger)section
{
    return (section == 0 ) ? self.friends  : self.otherUsers;
}

@end
