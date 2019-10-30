//
//  QMContactsSearchDataSource.m
//  Q-municate
//
//  Created by Injoit on 3/17/16.
//  Copyright © 2016 QuickBlox. All rights reserved.
//

#import "QMContactsSearchDataSource.h"
#import "QMNoResultsCell.h"
#import "QMContactCell.h"
#import "QMCore.h"

@implementation QMContactsSearchDataSource

- (CGFloat)heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return self.isEmpty ? [QMNoResultsCell height] : [QMContactCell height];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.isEmpty) {
        
        QMNoResultsCell *cell =
        [tableView dequeueReusableCellWithIdentifier:[QMNoResultsCell cellIdentifier]
                                        forIndexPath:indexPath];
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        return cell;
    }
    
    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    QMContactCell *cell = [tableView dequeueReusableCellWithIdentifier:[QMContactCell cellIdentifier]
                                                          forIndexPath:indexPath];
    
    QBUUser *user = [self userAtIndexPath:indexPath];
    [cell setTitle:user.fullName avatarUrl:user.avatarUrl];
    
    [cell setBody:[QMCore.instance.contactManager onlineStatusForUser:user]];
    
    return cell;
}

@end
