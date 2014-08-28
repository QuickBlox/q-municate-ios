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



@implementation QMContactRequestDataSource


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
    if (indexPath.section == 0) {
        QMContactRequestCell *cell = (QMContactRequestCell *)[tableView dequeueReusableCellWithIdentifier:kQMContactRequestCellIdentifier];
        QBUUser *user = self.otherUsers[indexPath.row];
        cell.userData = user;
        return cell;
    }
    if (self.friends.count == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kQMDontHaveAnyFriendsCellIdentifier];
        return cell;
    }
    return nil;
}

@end
