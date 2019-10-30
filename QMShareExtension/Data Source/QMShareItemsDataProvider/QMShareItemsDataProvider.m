//
//  QMShareItemsDataProvider.m
//  QMShareExtension
//
//  Created by Injoit on 10/10/17.
//  Copyright © 2017 QuickBlox. All rights reserved.
//

#import "QMShareItemsDataProvider.h"
#import "QMSearchProtocols.h"

@interface QMShareItemsDataProvider()

@property (copy, nonatomic) NSString *cachedSearchText;
@property (strong, nonatomic) NSArray *shareItems;

@end

@implementation QMShareItemsDataProvider

- (instancetype)initWithShareItems:(NSArray *)shareItems {
    
    if (self = [super init]) {
        
        _shareItems = shareItems;
    }
    
    return self;
}

- (void)performSearch:(NSString *)searchText {
    
    if (![_cachedSearchText isEqualToString:searchText]) {
        
        self.cachedSearchText = searchText;
    }
    
    if (searchText.length == 0) {
        
        [self.dataSource replaceItems:self.shareItems];
        [self.delegate searchDataProviderDidFinishDataFetching:self];
        
        return;
    }

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
     
        NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"SELF.title CONTAINS[cd] %@", searchText];
        NSArray *searchResult = [self.shareItems filteredArrayUsingPredicate:searchPredicate];
        
        [self.dataSource replaceItems:searchResult];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.delegate searchDataProviderDidFinishDataFetching:self];
        });
    });
}


- (void)performSearch:(NSString *)searchText
           dataSource:(QMDataSource *)dataSource {
    
    if (![_cachedSearchText isEqualToString:searchText]) {
        
        self.cachedSearchText = searchText;
    }
    
    if (searchText.length == 0) {
        
        [dataSource replaceItems:self.shareItems];
        [self.delegate searchDataProviderDidFinishDataFetching:self];
        
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"SELF.title CONTAINS[cd] %@", searchText];
        NSArray *searchResult = [self.shareItems filteredArrayUsingPredicate:searchPredicate];
        
        [dataSource replaceItems:searchResult];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.delegate searchDataProviderDidFinishDataFetching:self];
        });
    });
    
}


@end
