//
//  QMSearchDataSource.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 3/2/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMSearchDataSource.h"
#import "QMSearchDataProvider.h"

@implementation QMSearchDataSource

@synthesize searchDataProvider = _searchDataProvider;

- (instancetype)initWithSearchDataProvider:(QMSearchDataProvider *)searchDataProvider {
    
    self = [super init];
    
    if (self) {
        
        _searchDataProvider = searchDataProvider;
        _searchDataProvider.dataSource = self;
    }
    
    return self;
}

- (void)performSearch:(NSString *)searchText {
    
    [self.searchDataProvider performSearch:searchText
                                dataSource:self];
}


@end
