//
//  QMContactsSearchDataProvider.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 3/17/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMContactsSearchDataProvider.h"
#import "QMSearchProtocols.h"
#import "QMCore.h"

@interface QMContactsSearchDataProvider ()

<
QMContactListServiceDelegate,
QMUsersServiceDelegate
>

@property (copy, nonatomic) NSString *cachedSearchText;

@end

@implementation QMContactsSearchDataProvider

#pragma mark - Construction

- (instancetype)init {
    
    self = [super init];
    
    if (self) {
        
        [[QMCore instance].contactListService addDelegate:self];
        [[QMCore instance].usersService addDelegate:self];
        _friends = [[QMCore instance].contactManager friends];
    }
    
    return self;
}

#pragma mark - Methods

- (void)performSearch:(NSString *)searchText {
    
    if (![_cachedSearchText isEqualToString:searchText]) {
        
        self.cachedSearchText = searchText;
    }
    
    if (searchText.length == 0) {
        
        [self.dataSource replaceItems:self.friends];
        [self.delegate searchDataProviderDidFinishDataFetching:self];
        
        return;
    }
    
    @weakify(self);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        @strongify(self);
        NSPredicate *usersSearchPredicate = [NSPredicate predicateWithFormat:@"SELF.fullName CONTAINS[cd] %@", searchText];
        NSArray *friendsSearchResult = [self.friends filteredArrayUsingPredicate:usersSearchPredicate];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.dataSource replaceItems:friendsSearchResult];
            [self.delegate searchDataProviderDidFinishDataFetching:self];
        });
    });
}

#pragma mark - Helpers

- (void)updateData {
    
    self.friends = [[QMCore instance].contactManager friends];
    [self performSearch:self.cachedSearchText];
    
    [self.delegate searchDataProvider:self didUpdateData:self.friends];
}

#pragma mark - QMUsersServiceDelegate

- (void)usersService:(QMUsersService *)__unused usersService didLoadUsersFromCache:(NSArray<QBUUser *> *)__unused users {
    
    [self updateData];
}

- (void)usersService:(QMUsersService *)__unused usersService didAddUsers:(NSArray<QBUUser *> *)__unused user {
    
    [self updateData];
}

#pragma mark - QMContactListDelegate

- (void)contactListServiceDidLoadCache {
    
    [self updateData];
}

- (void)contactListService:(QMContactListService *)__unused contactListService contactListDidChange:(QBContactList *)__unused contactList {
    
    [self updateData];
}

@end
