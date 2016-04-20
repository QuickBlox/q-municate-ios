//
//  QMGlobalSearchDataSource.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 3/1/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMGlobalSearchDataSource.h"
#import "QMSearchCell.h"
#import "QMNoResultsCell.h"
#import "QMCore.h"

@interface QMGlobalSearchDataSource ()

@property (weak, nonatomic) BFTask *addUserTask;

@end

@implementation QMGlobalSearchDataSource

- (CGFloat)heightForRowAtIndexPath:(NSIndexPath *)__unused indexPath {
    
    return self.items.count > 0 ? [QMSearchCell height] : [QMNoResultsCell height];
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.items.count == 0) {
        
        QMNoResultsCell *cell = [tableView dequeueReusableCellWithIdentifier:[QMNoResultsCell cellIdentifier] forIndexPath:indexPath];
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        return cell;
    }
    
    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    QMSearchCell *cell = [tableView dequeueReusableCellWithIdentifier:[QMSearchCell cellIdentifier] forIndexPath:indexPath];
    
    QBUUser *user = self.items[indexPath.row];
    
    [cell setTitle:user.fullName placeholderID:user.ID avatarUrl:user.avatarUrl];
    [cell setUser:user];
    
    cell.delegate = self;
    
    if (indexPath.row == [tableView numberOfRowsInSection:0] - 1) {
        
        [self.globalSearchDataProvider nextPage];
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)__unused tableView numberOfRowsInSection:(NSInteger)__unused section {
    
    return self.items.count > 0 ? self.items.count : 1;
}

#pragma mark - QMGlobalSearchDataProvider

- (QMGlobalSearchDataProvider *)globalSearchDataProvider {
    
    return (id)self.searchDataProvider;
}

#pragma mark - QMContactCellDelegate

- (void)searchCell:(QMSearchCell *)searchCell didTapAddButton:(UIButton *)__unused sender {
    
    if (self.addUserTask) {
        
        return;
    }
    
    QBContactListItem *contactListItem = [[QMCore instance].contactListService.contactListMemoryStorage contactListItemWithUserID:searchCell.user.ID];
    
    if (contactListItem.subscriptionState == QBPresenceSubscriptionStateFrom) {
        
        self.addUserTask = [[QMCore instance].contactManager confirmAddContactRequest:searchCell.user];
    }
    else {
        
        self.addUserTask = [[QMCore instance].contactManager addUserToContactList:searchCell.user];
    }
}

@end
