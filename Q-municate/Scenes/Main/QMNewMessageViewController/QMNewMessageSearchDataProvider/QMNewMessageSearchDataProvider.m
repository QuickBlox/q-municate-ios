//
//  QMNewMessageSearchDataProvider.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 3/17/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMNewMessageSearchDataProvider.h"
#import "QMSearchProtocols.h"
#import "QMCore.h"

@interface QMNewMessageSearchDataProvider ()

<
QMContactListServiceDelegate,
QMUsersServiceDelegate
>

@property (strong, nonatomic) NSString *cachedSearchText;

@end

@implementation QMNewMessageSearchDataProvider

- (instancetype)init {
    
    self = [super init];
    
    if (self) {
        
        [[QMCore instance].contactListService addDelegate:self];
        [[QMCore instance].usersService addDelegate:self];
        _friends = [QMCore instance].friends;
    }
    
    return self;
}

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

- (void)usersService:(QMUsersService *)usersService didLoadUsersFromCache:(NSArray<QBUUser *> *)users {
    
    self.friends = [QMCore instance].friends;
    [self performSearch:self.cachedSearchText];
    
    if ([self.delegate respondsToSelector:@selector(searchDataProvider:didUpdateData:)]) {
        
        [self.delegate searchDataProvider:self didUpdateData:self.friends];
    }
}

- (void)usersService:(QMUsersService *)usersService didAddUsers:(NSArray<QBUUser *> *)user {
    
    self.friends = [QMCore instance].friends;
    [self performSearch:self.cachedSearchText];
    
    if ([self.delegate respondsToSelector:@selector(searchDataProvider:didUpdateData:)]) {
        
        [self.delegate searchDataProvider:self didUpdateData:self.friends];
    }
}

#pragma mark - QMContactListDelegate

- (void)contactListServiceDidLoadCache {
    
    self.friends = [QMCore instance].friends;
    [self performSearch:self.cachedSearchText];
    
    if ([self.delegate respondsToSelector:@selector(searchDataProvider:didUpdateData:)]) {
        
        [self.delegate searchDataProvider:self didUpdateData:self.friends];
    }
}

- (void)contactListService:(QMContactListService *)contactListService contactListDidChange:(QBContactList *)contactList {
    
    self.friends = [QMCore instance].friends;
    [self performSearch:self.cachedSearchText];
    
    if ([self.delegate respondsToSelector:@selector(searchDataProvider:didUpdateData:)]) {
        
        [self.delegate searchDataProvider:self didUpdateData:self.friends];
    }
}

@end
