//
//  QMSearchResultsController.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 2/29/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMSearchResultsController.h"
#import "QMTableViewDataSource.h"
#import "QMLocalSearchDataSource.h"
#import "QMCore.h"
#import "QMLocalSearchDataProvider.h"

#import "QMDialogCell.h"
#import "QMContactCell.h"
#import "QMNoResultsCell.h"

@interface QMSearchResultsController ()

<
UITableViewDelegate,
QMContactListServiceDelegate,
QMUsersServiceDelegate,
QMChatServiceDelegate,
QMChatConnectionDelegate
>

@end

@implementation QMSearchResultsController

- (instancetype)init {
    
    if (self = [super init]) {
        
        [self registerNibs];
        
        [[QMCore instance].chatService addDelegate:self];
        [[QMCore instance].contactListService addDelegate:self];
        [[QMCore instance].usersService addDelegate:self];
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
    [QMContactCell registerForReuseInTableView:self.tableView];
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

#pragma mark - QMContactListServiceDelegate

- (void)contactListService:(QMContactListService *)contactListService contactListDidChange:(QBContactList *)contactList {
    
    [self.tableView reloadData];
}

- (void)contactListService:(QMContactListService *)contactListService didReceiveContactItemActivity:(NSUInteger)userID isOnline:(BOOL)isOnline status:(NSString *)status {
    
    [self.tableView reloadData];
}

- (void)contactListServiceDidLoadCache {
    
    [self.tableView reloadData];
}

#pragma mark - QMUsersServiceDelegate

- (void)usersService:(QMUsersService *)usersService didLoadUsersFromCache:(NSArray<QBUUser *> *)users {
    
    [self.tableView reloadData];
}

@end
