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
    if ((indexPath.row == (int)self.collection.count) && self.totalEntries != self.loaded) {
        
        QMSearchStatusCell *cell = [tableView dequeueReusableCellWithIdentifier:QMSearchStatusCell.cellIdentifier
                                                                   forIndexPath:indexPath];
        NSString *tile = @"Loading..";
        [cell setTitle:tile];
        
        cell.showActivityIndicator = YES;
        
        return cell;
    }
    else if ((indexPath.row == (int)self.collection.count) && self.totalEntries == self.loaded) {
        
        QMSearchStatusCell *cell = [tableView dequeueReusableCellWithIdentifier:QMSearchStatusCell.cellIdentifier
                                                                   forIndexPath:indexPath];
        
        NSString *title = [NSString stringWithFormat:@"No more results"];
        [cell setTitle:title];
        
        cell.showActivityIndicator = NO;
        
        return cell;
    }
    
    else {
        //Contact cell
        QMContactCell *cell = [tableView dequeueReusableCellWithIdentifier:QMContactCell.cellIdentifier
                                                              forIndexPath:indexPath];
        cell.delegate = self.addContactHandler;
        cell.contact = self.collection[indexPath.row];
        [cell highlightText:self.searchText];
        
        return cell;
    }
    
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.collection.count + 1;
}

@end
