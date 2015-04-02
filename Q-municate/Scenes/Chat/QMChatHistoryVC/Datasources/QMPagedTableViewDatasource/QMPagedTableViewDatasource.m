//
//  QMPagedTableViewDatasource.m
//  Q-municate
//
//  Created by Andrey Ivanov on 01.04.15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import "QMPagedTableViewDatasource.h"

@interface QMPagedTableViewDatasource()

@property (strong, nonatomic) QBGeneralResponsePage *page;
@property (assign, nonatomic) NSUInteger totalEntries;
@property (assign, nonatomic) NSUInteger loaded;

@end

const NSUInteger kPerPage = 20;

@implementation QMPagedTableViewDatasource

- (instancetype)init {
    
    self = [super init];
    if (self) {
        
        self.page =
        [QBGeneralResponsePage responsePageWithCurrentPage:0
                                                   perPage:20];
        self.totalEntries = NSNotFound;
    }
    return self;
}

- (void)resetSearch {
    
    self.page.currentPage = 0;
    self.loaded = 0;
    self.totalEntries = NSNotFound;
}

- (void)updateCurrentPageWithResponcePage:(QBGeneralResponsePage *)page {
    
    if (self.totalEntries != NSNotFound && self.totalEntries != page.totalEntries) {
        NSAssert(nil, @"Need update this case");
        
    } else if(self.totalEntries == NSNotFound) {
        
        self.totalEntries = page.totalEntries;
    }
        
    NSUInteger loaded = self.page.currentPage * self.page.perPage;
    self.loaded = (loaded > page.totalEntries) ? page.totalEntries : loaded;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"object left %d" , page.totalEntries - self.loaded);
    });
}

- (QBGeneralResponsePage *)nextPage {
    
    if (self.loaded == self.totalEntries) {
        
        NSLog(@"All object loaded");
        return nil;
    }
    
    self.page.currentPage ++;
    
    return self.page;
}

@end
