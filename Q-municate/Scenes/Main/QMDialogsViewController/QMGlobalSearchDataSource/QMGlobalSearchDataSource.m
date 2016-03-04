//
//  QMGlobalSearchDataSource.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 3/1/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMGlobalSearchDataSource.h"
#import "QMContactCell.h"
#import "QMNoResultsCell.h"
#import "QMCore.h"

@interface QMGlobalSearchDataSource ()

@property (strong, nonatomic) BFTask *addUserTask;

@end

@implementation QMGlobalSearchDataSource

- (CGFloat)heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return self.items.count > 0 ? [QMContactCell height] : [QMNoResultsCell height];
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.items.count == 0) {
        
        QMNoResultsCell *cell = [tableView dequeueReusableCellWithIdentifier:[QMNoResultsCell cellIdentifier] forIndexPath:indexPath];
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        return cell;
    }
    
    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    QMContactCell *cell = [tableView dequeueReusableCellWithIdentifier:[QMContactCell cellIdentifier] forIndexPath:indexPath];
    
    QBUUser *user = self.items[indexPath.row];
    
    [cell setTitle:user.fullName placeholderID:user.ID avatarUrl:user.avatarUrl];
    
    QBContactListItem *item = [[QMCore instance].contactListService.contactListMemoryStorage contactListItemWithUserID:user.ID];
    [cell setContactListItem:item];
    [cell setUserID:user.ID];
    cell.delegate = self;
    
    if (indexPath.row == [tableView numberOfRowsInSection:0] - 1) {
        
        [self.globalSearchDataProvider nextPage];
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.items.count > 0 ? self.items.count : 1;
}

#pragma mark - QMGlobalSearchDataProvider

- (QMGlobalSearchDataProvider *)globalSearchDataProvider {
    
    return (id)self.searchDataProvider;
}

#pragma mark - QMContactCellDelegate

- (void)contactCell:(QMContactCell *)contactCell didTapAddButton:(UIButton *)sender {
    
    if (self.addUserTask) {
        
        return;
    }
    
    QBUUser *user = [[QMCore instance].usersService.usersMemoryStorage userWithID:contactCell.userID];
    
    QBContactListItem *contactListItem = contactCell.contactListItem;
    
    @weakify(self);
    BFContinuationBlock completionBlock = ^id _Nullable(BFTask * _Nonnull task) {
        @strongify(self);
        self.addUserTask = nil;
        return nil;
    };
    
    if (contactListItem.subscriptionState == QBPresenceSubscriptionStateFrom) {
        
        self.addUserTask = [[[QMCore instance].contactListService acceptContactRequest:user.ID] continueWithBlock:completionBlock];
    }
    else {
        
        self.addUserTask = [[[QMCore instance].contactListService addUserToContactListRequest:user] continueWithBlock:completionBlock];
    }
}

@end
