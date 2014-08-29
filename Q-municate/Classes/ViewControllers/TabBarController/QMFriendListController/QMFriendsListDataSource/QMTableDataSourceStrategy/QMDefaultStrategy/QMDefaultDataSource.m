//
//  QMDefaultDataSource.m
//  Q-municate
//
//  Created by Igor Alefirenko on 29/08/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMDefaultDataSource.h"
#import "QMFriendsListDataSource.h"
#import "QMFriendListCell.h"
#import "QMApi.h"

@implementation QMDefaultDataSource


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.friends.count > 0 ? NSLocalizedString(@"QM_STR_FRIENDS", nil) : nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.friends.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.friends.count == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kQMDontHaveAnyFriendsCellIdentifier];
        return cell;
    }
    
    QMFriendListCell *cell = [tableView dequeueReusableCellWithIdentifier:kQMFriendsListCellIdentifier];
    QBUUser *user = self.friends[indexPath.row];
    QBContactListItem *item = [[QMApi instance] contactItemWithUserID:user.ID];
    cell.contactlistItem = item;
    cell.userData = user;
    
    return cell;
}

@end
