//
//  QMDataSource.m
//  Q-municate
//
//  Created by Vitaliy Gurkovsky on 10/10/17.
//  Copyright © 2017 Quickblox. All rights reserved.
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

- (id)objectAtIndexPath:(NSIndexPath *)__unused indexPath {
    
    return nil;
}

- (NSIndexPath *)indexPathForObject:(id)__unused object {
    
    return nil;
}

- (void)addItems:(NSArray *)items {
    
    [self.items addObjectsFromArray:items];
}

- (void)updateItems:(NSArray *)__unused items {
    NSAssert(NO, @"Should be implemented in subclass");
}

- (void)replaceItems:(NSArray *)items {
    
    [self.items removeAllObjects];
    
    items == nil ?: [self.items addObjectsFromArray:items];
}

@end
