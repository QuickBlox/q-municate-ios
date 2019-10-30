//
//  QMDataSource.m
//  Q-municate
//
//  Created by Injoit on 10/10/17.
//  Copyright © 2017 QuickBlox. All rights reserved.
//

#import "QMDataSource.h"

@implementation QMDataSource

- (instancetype)init {
    
    self = [super init];
    
    if (self) {
        _items = [NSMutableArray array];
    }
    
    return self;
}

- (id)objectAtIndexPath:(NSIndexPath *)indexPath {
    
    return nil;
}

- (NSIndexPath *)indexPathForObject:(id) object {
    
    return nil;
}

- (void)addItems:(NSArray *)items {
    
    [self.items addObjectsFromArray:items];
}

- (void)updateItems:(NSArray *)items {
    NSAssert(NO, @"Should be implemented in subclass");
}

- (void)replaceItems:(NSArray *)items {
    
    [self.items removeAllObjects];
    
    items == nil ?: [self.items addObjectsFromArray:items];
}

@end
