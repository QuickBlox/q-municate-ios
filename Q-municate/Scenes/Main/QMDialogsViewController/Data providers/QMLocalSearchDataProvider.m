//
//  QMLocalSearchDataProvider.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 3/2/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMLocalSearchDataProvider.h"
#import "QMLocalSearchDataSource.h"
#import "QMSearchProtocols.h"
#import "QMCore.h"

static NSString *const kQMDialogsSearchDescriptorKey = @"name";

@interface QMLocalSearchDataProvider ()

<
QMContactListServiceDelegate,
QMUsersServiceDelegate
>

@property (strong, nonatomic) NSArray *contacts;

@end

@implementation QMLocalSearchDataProvider

- (instancetype)init {
    
    self = [super init];
    
    if (self) {
        
        [[QMCore instance].contactListService addDelegate:self];
        [[QMCore instance].usersService addDelegate:self];
        _contacts = [QMCore instance].allContactsSortedByFullName;
    }
    
    return self;
}

- (void)performSearch:(NSString *)searchText {
    
    if (![self.dataSource conformsToProtocol:@protocol(QMLocalSearchDataSourceProtocol)]) {
        
        return;
    }
    
    QMSearchDataSource <QMLocalSearchDataSourceProtocol> *dataSource = (id)self.dataSource;
    
    if (searchText.length == 0) {
        
        [dataSource.contacts removeAllObjects];
        [dataSource.dialogs removeAllObjects];
        [self callDelegate];
        return;
    }
    
    @weakify(self);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        @strongify(self);
        // contacts local search
        NSPredicate *usersSearchPredicate = [NSPredicate predicateWithFormat:@"SELF.fullName CONTAINS[cd] %@", searchText];
        NSArray *contactsSearchResult = [self.contacts filteredArrayUsingPredicate:usersSearchPredicate];
        
        // dialogs local search
        NSSortDescriptor *dialogsSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:kQMDialogsSearchDescriptorKey ascending:NO];
        NSArray *dialogs = [[QMCore instance].chatService.dialogsMemoryStorage dialogsWithSortDescriptors:@[dialogsSortDescriptor]];
        
        NSPredicate *dialogsSearchPredicate = [NSPredicate predicateWithFormat:@"SELF.name CONTAINS[cd] %@", searchText];
        NSMutableArray *dialogsSearchResult = [NSMutableArray arrayWithArray:[dialogs filteredArrayUsingPredicate:dialogsSearchPredicate]];
        
        [dataSource setContacts:contactsSearchResult.mutableCopy];
        [dataSource setDialogs:dialogsSearchResult];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self callDelegate];
        });
    });
}

- (void)callDelegate {
    
    if ([self.delegate respondsToSelector:@selector(searchDataProviderDidFinishDataFetching:)]) {
        
        [self.delegate searchDataProviderDidFinishDataFetching:self];
    }
}

#pragma mark - QMContactListServiceDelegate

- (void)contactListService:(QMContactListService *)contactListService contactListDidChange:(QBContactList *)contactList {
    
    self.contacts = [QMCore instance].allContactsSortedByFullName;
}

- (void)contactListService:(QMContactListService *)contactListService didReceiveContactItemActivity:(NSUInteger)userID isOnline:(BOOL)isOnline status:(NSString *)status {
    
    self.contacts = [QMCore instance].allContactsSortedByFullName;
}

- (void)contactListServiceDidLoadCache {
    
    self.contacts = [QMCore instance].allContactsSortedByFullName;
}

#pragma mark - QMUsersServiceDelegate

- (void)usersService:(QMUsersService *)usersService didAddUsers:(NSArray<QBUUser *> *)user {
    
    self.contacts = [QMCore instance].allContactsSortedByFullName;
}

- (void)usersService:(QMUsersService *)usersService didLoadUsersFromCache:(NSArray<QBUUser *> *)users {
    
    self.contacts = [QMCore instance].allContactsSortedByFullName;
}

@end
