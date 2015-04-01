//
//  QMSearchChatHistoryDatasource.m
//  Q-municate
//
//  Created by Andrey Ivanov on 11.03.15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import "QMSearchChatHistoryDatasource.h"

#import "QMChatHistoryCell.h"
#import "QMContactCell.h"
#import "QMSearchStatusCell.h"

@implementation QMSearchChatHistoryDatasource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //Loading Cell
    if (self.loading && self.collection.count == 0) {
        
        QMSearchStatusCell *cell = [tableView dequeueReusableCellWithIdentifier:QMSearchStatusCell.cellIdentifier
                                                                   forIndexPath:indexPath];
        [cell setTitle:@"Loading.."];
        cell.showActivityIndicator = YES;
        
        return cell;
    }
    else {
        //Contact cell
        QMContactCell *cell = [tableView dequeueReusableCellWithIdentifier:QMContactCell.cellIdentifier
                                                              forIndexPath:indexPath];
        cell.delegate = self.addContactHandler;
        cell.contact = self.collection[indexPath.row];
        
        return cell;
    }

    return nil;
}

- (void)setObjects:(NSArray *)objects {
    
    [self.collection removeAllObjects];
    [self.collection addObjectsFromArray:objects];
}

@end
