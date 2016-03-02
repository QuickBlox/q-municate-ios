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
static NSString *const kQMDialogsSearchDescriptorKey = @"name";

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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    
    [[QMCore instance].contactListService addDelegate:self];
    self.friends = [QMCore instance].friendsSortedByFullName;
    
    // Hide empty separators
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

#pragma mark Search methods

- (void)performSearch:(NSString *)searchText {
    
    BOOL isLocalSearch = [self.searchDataSource conformsToProtocol:@protocol(QMLocalSearchDataSourceProtocol)];
    
    isLocalSearch ? [self localSearch:searchText] : [self globalSearch:searchText];
}

- (void)localSearch:(NSString *)searchText {
    
    if (searchText.length == 0) {
        
        [self.searchDataSource.contacts removeAllObjects];
        [self.searchDataSource.dialogs removeAllObjects];
        [self.tableView reloadData];
        return;
    }
    
    @weakify(self);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        @strongify(self);
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
        
        NSSortDescriptor *dialogsSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:kQMDialogsSearchDescriptorKey ascending:NO];
        NSArray *dialogs = [[QMCore instance].chatService.dialogsMemoryStorage dialogsWithSortDescriptors:@[dialogsSortDescriptor]];
        
        NSPredicate *dialogsSearchPredicate = [NSPredicate predicateWithFormat:@"SELF.name CONTAINS[cd] %@", searchText];
        [dialogsSearchResult addObjectsFromArray:[dialogs filteredArrayUsingPredicate:dialogsSearchPredicate]];
        
        [self.searchDataSource setContacts:contactsSearchResult.mutableCopy];
        [self.searchDataSource setDialogs:dialogsSearchResult];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.tableView reloadData];
        });
    });
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
    NSMutableArray *searchItems = self.searchDataSource.items;
    
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
    
    return [self.searchDataSource heightForRowAtIndexPath:indexPath];
}

#pragma mark - Register nibs

- (void)registerNibs {
    
    [QMDialogCell registerForReuseInTableView:self.tableView];
    [QMContactCell registerForReuseInTableView:self.tableView];
}

#pragma mark - QMSearchProtocol

- (QMTableViewDataSource<QMLocalSearchDataSourceProtocol> *)searchDataSource {
    
    return (id)self.tableView.dataSource;
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
