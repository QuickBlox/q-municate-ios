//
//  QMTableViewDataSource.m
//  Q-municate
//
//  Created by Andrey Ivanov on 01.04.15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import "QMTableViewDatasource.h"
#import "QMSearchDataProvider.h"

@implementation QMTableViewDataSource

- (instancetype)init {
    
    self = [super init];
    if (self) {
        
        _items = [NSMutableArray array];
    }
    return self;
}

- (id)objectAtIndexPath:(NSIndexPath *)__unused indexPath {
    
    return nil;
}

- (CGFloat)heightForRowAtIndexPath:(NSIndexPath *)__unused indexPath {
    
    return 0.0f;
}

- (NSInteger)tableView:(UITableView *)__unused tableView numberOfRowsInSection:(NSInteger)__unused section {
    
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)__unused tableView cellForRowAtIndexPath:(NSIndexPath *)__unused indexPath {
    
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
