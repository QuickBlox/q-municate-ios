//
//  QMChatHistoryDatasource.m
//  Q-municate
//
//  Created by Andrey Ivanov on 11.03.15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import "QMChatHistoryDatasource.h"
#import "QMChatHistoryCell.h"

@implementation QMChatHistoryDatasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.collection.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    QMChatHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"QMChatHistoryCell" forIndexPath:indexPath];
    QBUUser *user = self.collection[indexPath.row];

    [cell setTitle:user.fullName];
    [cell setTime:@"6.02.15"];
    [cell setSubTitle:@"Alex Bass: Donec sed odio dui. Nullam id dylor id nibh"];
    
    return cell;
}

@end
