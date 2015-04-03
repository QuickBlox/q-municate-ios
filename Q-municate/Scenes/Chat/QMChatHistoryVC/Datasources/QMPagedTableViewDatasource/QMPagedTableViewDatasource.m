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
@property (assign, nonatomic) NSUInteger loadedEntries;

@end

const NSUInteger kPerPage = 20;

@implementation QMPagedTableViewDatasource

- (instancetype)init {
    
    self = [super init];
    if (self) {
        
        self.page = [QBGeneralResponsePage responsePageWithCurrentPage:0 perPage:20];
        self.totalEntries = NSNotFound;
    }
    
    return self;
}

- (void)resetPage {
    
    [self.collection removeAllObjects];
    self.page.currentPage = 0;
    self.loadedEntries = 0;
    self.totalEntries = NSNotFound;
}

- (void)updateCurrentPageWithResponcePage:(QBGeneralResponsePage *)page {
    
    if (self.totalEntries != NSNotFound &&
        self.totalEntries != page.totalEntries) {
        
        NSLog(@"QBGeneralResponsePage.totalentries changed!!!");
        self.totalEntries = page.totalEntries;
        
    } else if(self.totalEntries == NSNotFound) {
        
        self.totalEntries = page.totalEntries;
    }
        
    NSUInteger loadedEntries = self.page.currentPage * self.page.perPage;
    self.loadedEntries = (loadedEntries > page.totalEntries) ? page.totalEntries : loadedEntries;
}

- (QBGeneralResponsePage *)nextPage {
    
    if (self.loadedEntries == self.totalEntries) {
        //All entries loaded
        return nil;
    }
    
    self.page.currentPage ++;
    
    return self.page;
}

- (NSString *)description {
    
    return [NSString stringWithFormat:@"Total entries:%ld; loaded entries:%ld; currentPage:%ld",
            (long)self.totalEntries, (long)self.loadedEntries, self.page.currentPage];
}

@end
