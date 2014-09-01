//
//  QMContactRequestDataSource.m
//  Q-municate
//
//  Created by Igor Alefirenko on 28/08/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMContactRequestDataSource.h"
#import "QMFriendsListDataSource.h"
#import "QMContactRequestCell.h"
#import "QMApi.h"


@implementation QMContactRequestDataSource


#pragma mark - Table View Data Source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return self.otherUsers.count > 0 ? NSLocalizedString(@"QM_STR_REQUESTS", nil) : nil;
    }
    return self.friends.count > 0 ? NSLocalizedString(@"QM_STR_FRIENDS", nil) : nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
       return self.otherUsers.count;
    }
    return self.friends.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section > 0 && self.friends.count == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kQMDontHaveAnyFriendsCellIdentifier];
        return cell;
    }
    QMTableViewCell *cell = nil;
    QBUUser *user = nil;
    if (indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:kQMContactRequestCellIdentifier];
        ((QMContactRequestCell *)cell).delegate = self.friendsListDataSource;
        user = self.otherUsers[indexPath.row];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:kQMFriendsListCellIdentifier];
        user = self.friends[indexPath.row];
    }
    
    QBContactListItem *item = [[QMApi instance] contactItemWithUserID:user.ID];
    cell.contactlistItem = item;
    cell.userData = user;

    return cell;
}

@end
