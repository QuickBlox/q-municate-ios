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
#import "QMSearchCell.h"

@implementation QMGlobalSearchDataSource

- (id)objectAtIndexPath:(NSIndexPath *)indexPath {
    
    return self.items[indexPath.row];
}

- (CGFloat)heightForRowAtIndexPath:(NSIndexPath *)__unused indexPath {
    
    return self.items.count > 0 ? [QMSearchCell height] : [QMNoResultsCell height];
}

//MARK: - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.items.count == 0) {
        
        QMNoResultsCell *cell = [tableView dequeueReusableCellWithIdentifier:[QMNoResultsCell cellIdentifier] forIndexPath:indexPath];
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        return cell;
    }
    
    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    QMSearchCell *cell = [tableView dequeueReusableCellWithIdentifier:[QMSearchCell cellIdentifier] forIndexPath:indexPath];
    
    QBUUser *user = self.items[indexPath.row];
    [cell setTitle:user.fullName avatarUrl:user.avatarUrl];
    
    if ([QBChat instance].isConnected) {
        // contact list is getting erased after
        // chat did disconnect
        // in order to save already visible value for
        // add button visibility, changing its state
        // only if chat is connected
        // default visibility value for add button is NO
        BOOL isRequestRequired = ![[QMCore instance].contactManager isContactListItemExistentForUserWithID:user.ID];
        [cell setAddButtonVisible:isRequestRequired];
    }
    
    cell.didAddUserBlock = self.didAddUserBlock;
    
    if (indexPath.row == [tableView numberOfRowsInSection:0] - 1) {
        
        [self.globalSearchDataProvider nextPage];
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)__unused tableView numberOfRowsInSection:(NSInteger)__unused section {
    
    return self.items.count > 0 ? self.items.count : 1;
}

//MARK: - QMGlobalSearchDataProvider

- (QMGlobalSearchDataProvider *)globalSearchDataProvider {
    
    return (id)self.searchDataProvider;
}

@end
