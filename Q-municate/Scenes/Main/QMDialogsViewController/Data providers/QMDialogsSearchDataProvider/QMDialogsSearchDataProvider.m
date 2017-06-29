//
//  QMDialogsSearchDataProvider.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 3/2/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMDialogsSearchDataProvider.h"
#import "QMDialogsSearchDataSource.h"
#import "QMSearchProtocols.h"
#import "QMCore.h"

static NSString *const kQMDialogsSearchDescriptorKey = @"name";

@implementation QMDialogsSearchDataProvider

- (void)performSearch:(NSString *)searchText {
    
    if (![self.dataSource conformsToProtocol:@protocol(QMDialogsSearchDataSourceProtocol)]) {
        
        return;
    }
    
    QMSearchDataSource <QMDialogsSearchDataSourceProtocol> *dataSource = (id)self.dataSource;
    
    if (searchText.length == 0) {
        
        [dataSource.items removeAllObjects];
        [self.delegate searchDataProviderDidFinishDataFetching:self];
        
        return;
    }
    
    @weakify(self);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        @strongify(self);
        
        // dialogs local search
        NSSortDescriptor *dialogsSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:kQMDialogsSearchDescriptorKey ascending:NO];
        NSArray *dialogs = [QMCore.instance.chatService.dialogsMemoryStorage dialogsWithSortDescriptors:@[dialogsSortDescriptor]];
        
        NSPredicate *dialogsSearchPredicate = [NSPredicate predicateWithFormat:@"SELF.name CONTAINS[cd] %@", searchText];
        NSMutableArray *dialogsSearchResult = [NSMutableArray arrayWithArray:[dialogs filteredArrayUsingPredicate:dialogsSearchPredicate]];
        
        [dataSource setItems:dialogsSearchResult];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.delegate searchDataProviderDidFinishDataFetching:self];
        });
    });
}

@end
