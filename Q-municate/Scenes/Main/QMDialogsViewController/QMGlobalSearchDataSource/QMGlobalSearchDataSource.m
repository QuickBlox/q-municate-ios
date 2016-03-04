//
//  QMGlobalSearchDataSource.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 3/1/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMGlobalSearchDataSource.h"
#import "QMContactCell.h"
#import "QMCore.h"

@implementation QMGlobalSearchDataSource

- (CGFloat)heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return [QMContactCell height];
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    QMContactCell *cell = [tableView dequeueReusableCellWithIdentifier:[QMContactCell cellIdentifier] forIndexPath:indexPath];
    
    QBUUser *user = self.items[indexPath.row];
    
    cell.placeholderID = user.ID;
    [cell setAvatarWithUrl:user.avatarUrl];
    [cell setTitle:user.fullName];
    
    QBContactListItem *item = [[QMCore instance].contactListService.contactListMemoryStorage contactListItemWithUserID:user.ID];
    [cell setContactListItem:item];
    
    if (indexPath.row == [tableView numberOfRowsInSection:0] - 1) {
        
        [self.globalSearchDataProvider nextPage];
    }
    
    return cell;
}

#pragma mark - QMGlobalSearchDataProvider

- (QMGlobalSearchDataProvider *)globalSearchDataProvider {
    
    return (id)self.searchDataProvider;
}

@end
