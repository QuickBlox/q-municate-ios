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

@property (strong, nonatomic) NSArray *datasource;
@property (strong, nonatomic) QBGeneralResponsePage *page;

@end

@implementation QMSearchChatHistoryDatasource

- (instancetype)init {
    
    self = [super init];
    if (self) {
        
        self.page =
        [QBGeneralResponsePage responsePageWithCurrentPage:1
                                                   perPage:100];
    }
    return self;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    QMChatHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"QMChatHistoryCell" forIndexPath:indexPath];
    
    return cell;
}

- (void)addObjects:(NSArray *)objects {
    
}

- (void)updateCurrentPageWithResponcePage:(QBGeneralResponsePage *)page {
    
    self.page.currentPage = page.currentPage + 1;
    self.page.perPage = 100;
}

- (QBGeneralResponsePage *)responsePage {
    
    return self.page;
}

@end
