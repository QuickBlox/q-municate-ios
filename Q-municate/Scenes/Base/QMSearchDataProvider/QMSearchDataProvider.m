//
//  QMSearchDataProvider.m
//  Q-municate
//
//  Created by Injoit on 3/2/16.
//  Copyright © 2016 QuickBlox. All rights reserved.
//

#import "QMSearchDataProvider.h"

@implementation QMSearchDataProvider

- (void)performSearch:(NSString *)searchText {
    
    if ([self.delegate respondsToSelector:@selector(searchDataProviderDidFinishDataFetching:)]) {
        
        [self.delegate searchDataProviderDidFinishDataFetching:self];
    }
}
- (void)performSearch:(NSString *)searchText
           dataSource:(QMDataSource *)dataSource {
    
    if ([self.delegate respondsToSelector:@selector(searchDataProviderDidFinishDataFetching:)]) {
        
        [self.delegate searchDataProviderDidFinishDataFetching:self];
    }
}

@end
