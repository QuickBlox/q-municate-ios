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

#import "QMDialogCell.h"
#import "QMContactCell.h"

static const NSTimeInterval kQMGlobalSearchTimeInterval = 0.6f;
static const NSUInteger kQMGlobalSearchCharsMin = 3;
static const NSUInteger kQMUsersPageLimit       = 50;

@interface QMSearchResultsController ()

<
UITableViewDelegate,
QMContactListServiceDelegate
>

// local search
@property (strong, nonatomic) NSArray *friends;

// global search timer
@property (strong, nonatomic) NSTimer *timer;

// global search pagination
@property (assign, nonatomic) NSUInteger currentPage;
@property (assign, nonatomic) BOOL shouldLoadMore;

@end

@implementation QMSearchResultsController

- (instancetype)init {
    
    if (self = [super init]) {
        
        [self registerNibs];
    }
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.tableView.delegate = self;
    
    self.friends = [QMCore instance].friendsSortedByFullName;
    
    // Hide empty separators
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

#pragma mark Search methods

- (void)localSearch:(NSString *)searchText {
    
    NSMutableArray *searchItems = [(QMTableViewDataSource *)self.tableView.dataSource items];
    
    if (searchText.length == 0) {
        
        [searchItems removeAllObjects];
        [self.tableView reloadData];
        return;
    }
    
    // contacts local search
    NSPredicate *usersSearchPredicate = [NSPredicate predicateWithFormat:@"SELF.fullName CONTAINS[cd] %@", searchText];
    NSArray *contactsSearchResult = [self.friends filteredArrayUsingPredicate:usersSearchPredicate];
    
    // dialogs local search
    NSMutableArray *dialogsSearchResult = [NSMutableArray array];
    
    NSArray *idsOfContacts = [[QMCore instance] idsOfUsers:contactsSearchResult];
    for (NSNumber *userID in idsOfContacts) {
        
        QBChatDialog *privateDialog = [[QMCore instance].chatService.dialogsMemoryStorage privateChatDialogWithOpponentID:[userID unsignedIntegerValue]];
        if (privateDialog != nil) {
            
            [dialogsSearchResult addObject:privateDialog];
        }
    }
    
    NSArray *dialogs = [QMCore instance].chatService.dialogsMemoryStorage.unsortedDialogs;
    
    NSPredicate *dialogsSearchPredicate = [NSPredicate predicateWithFormat:@"SELF.name CONTAINS[cd] %@", searchText];
    [dialogsSearchResult addObjectsFromArray:[dialogs filteredArrayUsingPredicate:dialogsSearchPredicate]];
    
    [(QMLocalSearchDataSource *)self.tableView.dataSource setContacts:contactsSearchResult];
    [(QMLocalSearchDataSource *)self.tableView.dataSource setDialogs:dialogsSearchResult.copy];
    
    [self.tableView reloadData];
}

- (void)globalSearch:(NSString *)searchText {
    
    // managing global search with timer
    [self.timer invalidate];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:kQMGlobalSearchTimeInterval
                                                  target:self
                                                selector:@selector(handleTimerForGlobalSearch:)
                                                userInfo:searchText
                                                 repeats:NO];
}

- (void)handleTimerForGlobalSearch:(NSTimer *)timer {
    
    // performing global search
    NSString *searchText = timer.userInfo;
    NSMutableArray *searchItems = [(QMTableViewDataSource *)self.tableView.dataSource items];
    
    if (searchText.length < kQMGlobalSearchCharsMin) {
        
        [searchItems removeAllObjects];
        [self.tableView reloadData];
        return;
    }
    
    QBGeneralResponsePage *page = [QBGeneralResponsePage responsePageWithCurrentPage:self.currentPage perPage:kQMUsersPageLimit];
    
    [[[QMCore instance].usersService searchUsersWithFullName:searchText page:page] continueWithBlock:^id _Nullable(BFTask<NSArray<QBUUser *> *> * _Nonnull task) {
        
        return nil;
    }];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([self.tableView.dataSource isKindOfClass:[QMLocalSearchDataSource class]]) {
        
        switch (indexPath.section) {
            case 0:
                
                return 50;
                
            case 1:
                
                return 72;
                
            default:
                return 0;
        }
    }
    else {
        
        return 50;
    }
}

#pragma mark - Register nibs

- (void)registerNibs {
    
    [QMDialogCell registerForReuseInTableView:self.tableView];
    [QMContactCell registerForReuseInTableView:self.tableView];
}

#pragma mark - 

#pragma mark - QMContactListServiceDelegate

- (void)contactListService:(QMContactListService *)contactListService contactListDidChange:(QBContactList *)contactList {
    
    self.friends = [QMCore instance].friendsSortedByFullName;
    [self.tableView reloadData];
}

- (void)contactListService:(QMContactListService *)contactListService didReceiveContactItemActivity:(NSUInteger)userID isOnline:(BOOL)isOnline status:(NSString *)status {
    
    self.friends = [QMCore instance].friendsSortedByFullName;
    [self.tableView reloadData];
}

- (void)contactListServiceDidLoadCache {
    
    self.friends = [QMCore instance].friendsSortedByFullName;
    [self.tableView reloadData];
}

@end
