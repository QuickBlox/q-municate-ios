//
//  QMChatHistoryDatasource.m
//  Q-municate
//
//  Created by Andrey Ivanov on 11.03.15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import "QMChatHistoryDatasource.h"
#import "QMChatHistoryCell.h"

@interface QMChatHistoryDatasource()

@property (strong, nonatomic) NSMutableArray *collection;

@end

@implementation QMChatHistoryDatasource

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.collection = [NSMutableArray array];
    }
    return self;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.collection.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    QMChatHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"QMChatHistoryCell" forIndexPath:indexPath];
    QBUUser *user = self.collection[indexPath.row];

    [cell setTitle:user.fullName];
    
    return cell;
}

@end
