//
//  QMSearchChatHistoryDatasource.m
//  Q-municate
//
//  Created by Andrey Ivanov on 11.03.15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import "QMSearchChatHistoryDatasource.h"

#import "QMChatHistoryCell.h"
#import "QMContactCell.h"
#import "QMSearchStatusCell.h"

@interface QMSearchChatHistoryDatasource()

@property (strong, nonatomic) NSMutableArray *collection;
@property (strong, nonatomic) QBGeneralResponsePage *page;

@end

@implementation QMSearchChatHistoryDatasource

- (instancetype)init {
    
    self = [super init];
    if (self) {
        
        self.collection = [NSMutableArray array];
        self.page =
        [QBGeneralResponsePage responsePageWithCurrentPage:1
                                                   perPage:100];
    }
    return self;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (self.loading && self.collection.count == 0) {
        return 1;
    }
    
    return self.collection.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //Loading Cell
    if (self.loading && self.collection.count == 0) {
        
        QMSearchStatusCell *cell = [tableView dequeueReusableCellWithIdentifier:QMSearchStatusCell.cellIdentifier
                                                                   forIndexPath:indexPath];
        [cell setTitle:@"Loading.."];
        cell.showActivityIndicator = YES;
        
        return cell;
    }
    else {
        //Contact cell
        QMContactCell *cell = [tableView dequeueReusableCellWithIdentifier:QMContactCell.cellIdentifier
                                                              forIndexPath:indexPath];
        QBUUser *user = self.collection[indexPath.row];
        [cell setTitle:user.fullName];
        
        return cell;
    }

    return nil;
}

- (void)setObjects:(NSArray *)objects {
    
    [self.collection removeAllObjects];
    [self.collection addObjectsFromArray:objects];
}

- (void)updateCurrentPageWithResponcePage:(QBGeneralResponsePage *)page {
    
    self.page.currentPage = page.currentPage + 1;
    self.page.perPage = 100;
}

- (QBGeneralResponsePage *)responsePage {
    
    return self.page;
}

@end
