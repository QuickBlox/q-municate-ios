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

@end

@implementation QMPagedTableViewDatasource

- (instancetype)init {
    
    self = [super init];
    if (self) {
        
        self.page =
        [QBGeneralResponsePage responsePageWithCurrentPage:1
                                                   perPage:100];
    }
    return self;
}

- (void)updateCurrentPageWithResponcePage:(QBGeneralResponsePage *)page {
    
    self.page.currentPage = page.currentPage + 1;
    self.page.perPage = 100;
}

- (QBGeneralResponsePage *)responsePage {
    
    return self.page;
}

@end
