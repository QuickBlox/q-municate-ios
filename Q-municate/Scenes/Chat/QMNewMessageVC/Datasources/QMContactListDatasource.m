//
//  QMContactListDatasource.m
//  Q-municate
//
//  Created by Andrey Ivanov on 03.04.15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import "QMContactListDatasource.h"
#import "QMContactCell.h"

@implementation QMContactListDatasource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    QMContactCell *cell = [tableView dequeueReusableCellWithIdentifier:QMContactCell.cellIdentifier
                                                          forIndexPath:indexPath];
    NSString *tile = @"Loading..";
    [cell setTitle:tile];
    
    return cell;
}

@end
