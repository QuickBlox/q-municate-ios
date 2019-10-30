//
//  QMTableViewDataSource.m
//  Q-municate
//
//  Created by Injoit on 01.04.15.
//  Copyright © 2015 QuickBlox. All rights reserved.
//

#import "QMTableViewDataSource.h"
#import "QMSearchDataProvider.h"

@implementation QMTableViewDataSource


- (id)objectAtIndexPath:(NSIndexPath *)indexPath {
    
    return nil;
}

- (NSIndexPath *)indexPathForObject:(id) object {
    
    return nil;
}

- (CGFloat)heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 0.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger) section {
    
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return nil;
}


@end

@implementation QMTableViewSearchDataSource

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
