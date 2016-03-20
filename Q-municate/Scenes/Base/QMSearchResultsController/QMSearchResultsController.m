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

- (void)searchDataProviderDidFinishDataFetching:(QMSearchDataProvider *)searchDataProvider {
    
    [self.tableView reloadData];
}

- (void)searchDataProvider:(QMSearchDataProvider *)searchDataProvider didUpdateData:(NSArray *)data {
    
    [self.tableView reloadData];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
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

- (void)chatService:(QMChatService *)chatService didAddMessagesToMemoryStorage:(NSArray<QBChatMessage *> *)messages forDialogID:(NSString *)dialogID {
    
    if ([self.searchDataSource conformsToProtocol:@protocol(QMLocalSearchDataSourceProtocol)]) {
        
        [self.tableView reloadData];
    }
}

- (void)chatService:(QMChatService *)chatService didAddMessageToMemoryStorage:(QBChatMessage *)message forDialogID:(NSString *)dialogID {
    
    if ([self.searchDataSource conformsToProtocol:@protocol(QMLocalSearchDataSourceProtocol)]) {
        
        [self.tableView reloadData];
    }
}

- (void)chatService:(QMChatService *)chatService didDeleteChatDialogWithIDFromMemoryStorage:(NSString *)chatDialogID {
    
    if ([self.searchDataSource conformsToProtocol:@protocol(QMLocalSearchDataSourceProtocol)]) {
        
        [self.tableView reloadData];
    }
}

- (void)chatService:(QMChatService *)chatService didReceiveNotificationMessage:(QBChatMessage *)message createDialog:(QBChatDialog *)dialog {
    
    if ([self.searchDataSource conformsToProtocol:@protocol(QMLocalSearchDataSourceProtocol)]) {
        
        [self.tableView reloadData];
    }
}

- (void)chatService:(QMChatService *)chatService didUpdateChatDialogInMemoryStorage:(QBChatDialog *)chatDialog {
    
    if ([self.searchDataSource conformsToProtocol:@protocol(QMLocalSearchDataSourceProtocol)]) {
        
        [self.tableView reloadData];
    }
}

- (void)chatService:(QMChatService *)chatService didUpdateChatDialogsInMemoryStorage:(NSArray<QBChatDialog *> *)dialogs {
    
    if ([self.searchDataSource conformsToProtocol:@protocol(QMLocalSearchDataSourceProtocol)]) {
        
        [self.tableView reloadData];
    }
}

@end
