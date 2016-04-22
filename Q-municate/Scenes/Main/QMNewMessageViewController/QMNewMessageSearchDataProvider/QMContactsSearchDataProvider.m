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

@property (strong, nonatomic) NSString *cachedSearchText;

@end

@implementation QMContactsSearchDataProvider

#pragma mark - Construction

- (instancetype)init {
    
    self = [super init];
    
    if (self) {
        
        [[QMCore instance].contactListService addDelegate:self];
        [[QMCore instance].usersService addDelegate:self];
        _friends = [QMCore instance].contactManager.friends;
    }
    
    return self;
}

#pragma mark - Methods

- (void)performSearch:(NSString *)searchText {
    
    if (![_cachedSearchText isEqualToString:searchText]) {
        
        _cachedSearchText = searchText;
    }
    
    if (searchText.length == 0) {
        
        [self.dataSource replaceItems:self.friends];
        if ([self.delegate respondsToSelector:@selector(searchDataProviderDidFinishDataFetching:)]) {
            
            [self.delegate searchDataProviderDidFinishDataFetching:self];
        }
        return;
    }
    
    @weakify(self);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        @strongify(self);
        NSPredicate *usersSearchPredicate = [NSPredicate predicateWithFormat:@"SELF.fullName CONTAINS[cd] %@", searchText];
        NSArray *friendsSearchResult = [self.friends filteredArrayUsingPredicate:usersSearchPredicate];
        
        [self.dataSource replaceItems:friendsSearchResult];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if ([self.delegate respondsToSelector:@selector(searchDataProviderDidFinishDataFetching:)]) {
                
                [self.delegate searchDataProviderDidFinishDataFetching:self];
            }
        });
    });
}

#pragma mark - QMUsersServiceDelegate

- (void)usersService:(QMUsersService *)__unused usersService didLoadUsersFromCache:(NSArray<QBUUser *> *)__unused users {
    
    self.friends = [QMCore instance].contactManager.friends;
    [self performSearch:self.cachedSearchText];
    
    if ([self.delegate respondsToSelector:@selector(searchDataProvider:didUpdateData:)]) {
        
        [self.delegate searchDataProvider:self didUpdateData:self.friends];
    }
}

- (void)usersService:(QMUsersService *)__unused usersService didAddUsers:(NSArray<QBUUser *> *)__unused user {
    
    self.friends = [QMCore instance].contactManager.friends;
    [self performSearch:self.cachedSearchText];
    
    if ([self.delegate respondsToSelector:@selector(searchDataProvider:didUpdateData:)]) {
        
        [self.delegate searchDataProvider:self didUpdateData:self.friends];
    }
}

#pragma mark - QMContactListDelegate

- (void)contactListServiceDidLoadCache {
    
    self.friends = [QMCore instance].contactManager.friends;
    [self performSearch:self.cachedSearchText];
    
    if ([self.delegate respondsToSelector:@selector(searchDataProvider:didUpdateData:)]) {
        
        [self.delegate searchDataProvider:self didUpdateData:self.friends];
    }
}

- (void)contactListService:(QMContactListService *)__unused contactListService contactListDidChange:(QBContactList *)__unused contactList {
    
    self.friends = [QMCore instance].contactManager.friends;
    [self performSearch:self.cachedSearchText];
    
    if ([self.delegate respondsToSelector:@selector(searchDataProvider:didUpdateData:)]) {
        
        [self.delegate searchDataProvider:self didUpdateData:self.friends];
    }
}

@end
