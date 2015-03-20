//
//  QMSearchChatHistoryDatasource.m
//  Q-municate
//
//  Created by Andrey Ivanov on 11.03.15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import "QMSearchChatHistoryDatasource.h"
#import "QMChatHistoryCell.h"

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
    
    return self.collection.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    QMChatHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"QMChatHistoryCell" forIndexPath:indexPath];
    QBUUser *user = self.collection[indexPath.row];
    
    [cell setTitle:user.fullName];
    [cell highlightText:self.searchText];
    
    return cell;
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
