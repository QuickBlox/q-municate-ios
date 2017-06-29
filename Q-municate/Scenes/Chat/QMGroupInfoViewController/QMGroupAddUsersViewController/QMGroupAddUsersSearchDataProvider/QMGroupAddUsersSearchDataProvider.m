//
//  QMGroupAddUsersSearchDataProvider.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 4/21/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMGroupAddUsersSearchDataProvider.h"
#import "QMCore.h"

@interface QMGroupAddUsersSearchDataProvider ()

<
QMContactListServiceDelegate,
QMUsersServiceDelegate
>

@property (copy, nonatomic) NSString *cachedSearchText;

@end

@implementation QMGroupAddUsersSearchDataProvider

//MARK: - Construction

- (instancetype)init {
    
    self = [super init];
    if (self) {
        
        [self commonInit];
    }
    
    return self;
}

- (instancetype)initWithExcludedUserIDs:(NSArray *)excludedUserIDs {
    
    self = [super init];
    if (self) {
        
        _excludedUserIDs = [excludedUserIDs copy];
        [self commonInit];
    }
    
    return self;
}

- (void)commonInit {
    
    [QMCore.instance.contactListService addDelegate:self];
    [QMCore.instance.usersService addDelegate:self];
    
    [self updateUsersAndCallDelegate:NO];
}

//MARK: - Methods

- (void)performSearch:(NSString *)searchText {
    
    if (![_cachedSearchText isEqualToString:searchText]) {
        
        self.cachedSearchText = searchText;
    }
    
    if (searchText.length == 0) {
        
        [self.dataSource replaceItems:self.users];
        [self.delegate searchDataProviderDidFinishDataFetching:self];
        
        return;
    }
    
    @weakify(self);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        @strongify(self);
        NSPredicate *usersSearchPredicate = [NSPredicate predicateWithFormat:@"SELF.fullName CONTAINS[cd] %@", searchText];
        NSArray *usersSearchResult = [self.users filteredArrayUsingPredicate:usersSearchPredicate];
        
        [self.dataSource replaceItems:usersSearchResult];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.delegate searchDataProviderDidFinishDataFetching:self];
        });
    });
}

//MARK: - Setters

- (void)setExcludedUserIDs:(NSArray *)excludedUserIDs {
    
    if (![_excludedUserIDs isEqualToArray:excludedUserIDs]) {
        
        _excludedUserIDs = excludedUserIDs;
        
        [self updateUsersAndCallDelegate:YES];
    }
}

//MARK: - Helpers

- (void)updateUsersAndCallDelegate:(BOOL)callDelegate {
    
    _users = [QMCore.instance.contactManager friendsByExcludingUsersWithIDs:_excludedUserIDs];
    
    if (callDelegate) {
        
        [self.delegate searchDataProvider:self didUpdateData:self.users];
    }
}

//MARK: - QMContactListServiceDelegate

- (void)contactListServiceDidLoadCache {
    
    [self updateUsersAndCallDelegate:YES];
}

- (void)contactListService:(QMContactListService *)__unused contactListService contactListDidChange:(QBContactList *)__unused contactList {
    
    [self updateUsersAndCallDelegate:YES];
}

//MARK: - QMUsersServiceDelegate

- (void)usersService:(QMUsersService *)__unused usersService didLoadUsersFromCache:(NSArray<QBUUser *> *)__unused users {
    
    [self updateUsersAndCallDelegate:YES];
}

- (void)usersService:(QMUsersService *)__unused usersService didAddUsers:(NSArray<QBUUser *> *)__unused user {
    
    [self updateUsersAndCallDelegate:YES];
}

@end
