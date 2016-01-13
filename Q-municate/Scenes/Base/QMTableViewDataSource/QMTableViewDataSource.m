//
//  QMTableViewDataSource.m
//  Q-municate
//
//  Created by Andrey Ivanov on 01.04.15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import "QMTableViewDatasource.h"

@implementation QMTableViewDataSource

- (instancetype)init {
    
    self = [super init];
    if (self) {
        
        _items = [NSMutableArray array];
    }
    return self;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return nil;
}

- (void)addItems:(NSArray *)items {
    
    [self.items addObjectsFromArray:items];
}

- (void)replaceItems:(NSArray *)items {
    
    [self.items removeAllObjects];
    [self.items addObjectsFromArray:items];
}

@end
