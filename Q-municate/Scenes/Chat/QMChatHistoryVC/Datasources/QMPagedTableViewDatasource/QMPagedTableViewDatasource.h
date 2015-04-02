//
//  QMPagedTableViewDatasource.h
//  Q-municate
//
//  Created by Andrey Ivanov on 01.04.15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import "QMTableViewDatasource.h"

@interface QMPagedTableViewDatasource : QMTableViewDatasource

@property (assign, nonatomic, readonly) NSUInteger totalEntries;
@property (assign, nonatomic, readonly) NSUInteger loaded;

- (void)resetSearch;
- (QBGeneralResponsePage *)nextPage;
- (void)updateCurrentPageWithResponcePage:(QBGeneralResponsePage *)page;

@end
