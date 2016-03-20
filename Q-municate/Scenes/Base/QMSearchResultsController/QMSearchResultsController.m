//
//  QMSearchResultsController.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 2/29/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMSearchResultsController.h"
#import "QMLocalSearchDataSource.h"
#import "QMCore.h"
#import "QMLocalSearchDataProvider.h"

#import "QMDialogCell.h"
#import "QMSearchCell.h"
#import "QMNoResultsCell.h"

@interface QMSearchResultsController ()

<
UITableViewDelegate,
QMChatServiceDelegate,
QMChatConnectionDelegate
>

@end

@implementation QMSearchResultsController

- (instancetype)init {
    
    if (self = [super init]) {
        
        [self registerNibs];
        
        [[QMCore instance].chatService addDelegate:self];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    
    // Hide empty separators
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

#pragma mark Search methods

- (void)performSearch:(NSString *)searchText {
    
    [self.searchDataSource.searchDataProvider performSearch:searchText];
}

#pragma mark - QMSearchDataProviderDelegate

- (void)searchDataProviderDidFinishDataFetching:(QMSearchDataProvider *)__unused searchDataProvider {
    
    [self.tableView reloadData];
}

- (void)searchDataProvider:(QMSearchDataProvider *)__unused searchDataProvider didUpdateData:(NSArray *)__unused data {
    
    [self.tableView reloadData];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)__unused tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return [self.searchDataSource heightForRowAtIndexPath:indexPath];
}

#pragma mark - Register nibs

- (void)registerNibs {
    
    [QMDialogCell registerForReuseInTableView:self.tableView];
    [QMSearchCell registerForReuseInTableView:self.tableView];
    [QMNoResultsCell registerForReuseInTableView:self.tableView];
}

#pragma mark - QMSearchProtocol

- (QMSearchDataSource *)searchDataSource {
    
    return (id)self.tableView.dataSource;
}

#pragma mark - QMChatServiceDelegate

- (void)chatService:(QMChatService *)__unused chatService didAddMessagesToMemoryStorage:(NSArray<QBChatMessage *> *)__unused messages forDialogID:(NSString *)__unused dialogID {
    
    if ([self.searchDataSource conformsToProtocol:@protocol(QMLocalSearchDataSourceProtocol)]) {
        
        [self.tableView reloadData];
    }
}

- (void)chatService:(QMChatService *)__unused chatService didAddMessageToMemoryStorage:(QBChatMessage *)__unused message forDialogID:(NSString *)__unused dialogID {
    
    if ([self.searchDataSource conformsToProtocol:@protocol(QMLocalSearchDataSourceProtocol)]) {
        
        [self.tableView reloadData];
    }
}

- (void)chatService:(QMChatService *)__unused chatService didDeleteChatDialogWithIDFromMemoryStorage:(NSString *)__unused chatDialogID {
    
    if ([self.searchDataSource conformsToProtocol:@protocol(QMLocalSearchDataSourceProtocol)]) {
        
        [self.tableView reloadData];
    }
}

- (void)chatService:(QMChatService *)__unused chatService didReceiveNotificationMessage:(QBChatMessage *)__unused message createDialog:(QBChatDialog *)__unused dialog {
    
    if ([self.searchDataSource conformsToProtocol:@protocol(QMLocalSearchDataSourceProtocol)]) {
        
        [self.tableView reloadData];
    }
}

- (void)chatService:(QMChatService *)__unused chatService didUpdateChatDialogInMemoryStorage:(QBChatDialog *)__unused chatDialog {
    
    if ([self.searchDataSource conformsToProtocol:@protocol(QMLocalSearchDataSourceProtocol)]) {
        
        [self.tableView reloadData];
    }
}

- (void)chatService:(QMChatService *)__unused chatService didUpdateChatDialogsInMemoryStorage:(NSArray<QBChatDialog *> *)__unused dialogs {
    
    if ([self.searchDataSource conformsToProtocol:@protocol(QMLocalSearchDataSourceProtocol)]) {
        
        [self.tableView reloadData];
    }
}

@end
