//
//  QMNewMessageSearchDataSource.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 3/17/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMNewMessageSearchDataSource.h"
#import "QMNoResultsCell.h"
#import "QMContactCell.h"
#import "QMCore.h"

@implementation QMNewMessageSearchDataSource

- (CGFloat)heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return self.sectionIndexTitles.count > 0 ? [QMContactCell height] : [QMNoResultsCell height];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.sectionIndexTitles.count == 0) {
        
        QMNoResultsCell *cell = [tableView dequeueReusableCellWithIdentifier:[QMNoResultsCell cellIdentifier] forIndexPath:indexPath];
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        return cell;
    }
    
    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    QMContactCell *cell = [tableView dequeueReusableCellWithIdentifier:[QMContactCell cellIdentifier] forIndexPath:indexPath];
    
    NSString *sectionKey = self.sectionIndexTitles[indexPath.section];
    NSArray *contacts = self.alphabetizedDictionary[sectionKey];
    QBUUser *user = contacts[indexPath.row];
    
    [cell setTitle:user.fullName placeholderID:user.ID avatarUrl:user.avatarUrl];
    
    QBContactListItem *item = [[QMCore instance].contactListService.contactListMemoryStorage contactListItemWithUserID:user.ID];
    [cell setContactListItem:item];
    [cell setUserID:user.ID];
    
    return cell;
}

@end
