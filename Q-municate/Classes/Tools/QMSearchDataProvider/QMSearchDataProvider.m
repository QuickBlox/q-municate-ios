//
//  QMSearchDataProvider.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 3/2/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMSearchDataProvider.h"

@implementation QMSearchDataProvider

- (void)performSearch:(NSString *)searchText {
    
    if ([self.delegate respondsToSelector:@selector(searchDataProviderDidFinishDataFetching:)]) {
        
        [self.delegate searchDataProviderDidFinishDataFetching:self];
    }
}

@end
