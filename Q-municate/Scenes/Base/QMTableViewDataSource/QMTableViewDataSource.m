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

- (instancetype)initWithSearchDataProvider:(QMSearchDataProvider *)searchDataProvider {
    
    self = [self init];
    
    if (self) {
        
        _searchDataProvider = searchDataProvider;
        _searchDataProvider.dataSource = self;
    }
    
    return self;
}

- (CGFloat)heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 0.0f;
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
