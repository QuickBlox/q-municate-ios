//
//  QMGlobalSearchDataProvider.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 3/3/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMGlobalSearchDataProvider.h"
#import "QMCore.h"

static const NSTimeInterval kQMGlobalSearchTimeInterval = 0.6f;
static const NSUInteger kQMGlobalSearchCharsMin = 3;
static const NSUInteger kQMUsersPageLimit = 50;

@interface QMGlobalSearchDataProvider () <QMContactListServiceDelegate>

@property (strong, nonatomic) BFCancellationTokenSource *globalSearchCancellationTokenSource;

@property (strong, nonatomic) NSTimer* timer;

@property (strong, nonatomic) QBGeneralResponsePage *responsePage;
@property (assign, nonatomic) BOOL shouldLoadMore;

@property (copy, nonatomic) NSString *cachedSearchText;
@property (assign, nonatomic) NSUInteger cachedSearchPage;

@end

@implementation QMGlobalSearchDataProvider

- (instancetype)init {
    
    self = [super init];
    
    if (self) {
        
        _responsePage = [QBGeneralResponsePage responsePageWithCurrentPage:1 perPage:kQMUsersPageLimit];
        
        [QMCore.instance.contactListService addDelegate:self];
    }
    
    return self;
}

- (void)performSearch:(NSString *)searchText {
    
    if (![self.dataSource conformsToProtocol:@protocol(QMGlobalSearchDataSourceProtocol)]) {
        
        return;
    }
    
    [self.timer invalidate];
    
    if (searchText.length < kQMGlobalSearchCharsMin) {
        
        [self.dataSource.items removeAllObjects];
        [self.delegate searchDataProviderDidFinishDataFetching:self];
        
        return;
    }
    
    [self cancel];
    
    if (![searchText isEqualToString:self.cachedSearchText]) {
        
        self.cachedSearchText = [searchText copy];
        self.responsePage.currentPage = 1;
    }
    else {
        
        //There is no need to perform the search for the same page and text
        if (self.cachedSearchPage == self.responsePage.currentPage) {
            return;
        }
    }
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:kQMGlobalSearchTimeInterval
                                                  target:self
                                                selector:@selector(globalSearch)
                                                userInfo:nil
                                                 repeats:NO];
}

- (void)globalSearch {
    
    self.globalSearchCancellationTokenSource = [BFCancellationTokenSource cancellationTokenSource];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    @weakify(self);
    [[QMCore.instance.usersService searchUsersWithFullName:self.cachedSearchText page:self.responsePage] continueWithBlock:^id _Nullable(BFTask<NSArray<QBUUser *> *> * _Nonnull task) {
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        @strongify(self);
        if (task.isCompleted) {
            
            self.cachedSearchPage = self.responsePage.currentPage;
            
            self.globalSearchCancellationTokenSource = nil;
            
            self.shouldLoadMore = task.result.count >= kQMUsersPageLimit;
            
            NSMutableArray *sortedUsers = [[self sortUsersByFullname:task.result] mutableCopy];
            [sortedUsers removeObject:QMCore.instance.currentProfile.userData];
    
            if (self.responsePage.currentPage > 1) {
                
                [self.dataSource addItems:[sortedUsers copy]];
            }
            else {
                
                [self.dataSource replaceItems:[sortedUsers copy]];
            }
            
            [self.delegate searchDataProviderDidFinishDataFetching:self];
        }
        
        return nil;
        
    } cancellationToken:self.globalSearchCancellationTokenSource.token];
}

//MARK: - Methods

- (void)nextPage {
    
    if (self.shouldLoadMore) {
        
        self.responsePage.currentPage++;
        [self performSearch:self.cachedSearchText];
    }
}

- (void)cancel {
    
    if (self.globalSearchCancellationTokenSource) {
        // cancel existing task if in progress
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [self.globalSearchCancellationTokenSource cancel];
    }
}

//MARK: - Helpers

- (NSArray *)sortUsersByFullname:(NSArray *)users {
    
    NSSortDescriptor *sorter = [[NSSortDescriptor alloc]
                                initWithKey:@keypath(QBUUser.new, fullName)
                                ascending:YES
                                selector:@selector(localizedCaseInsensitiveCompare:)];
    NSArray *sortedUsers = [users sortedArrayUsingDescriptors:@[sorter]];
    
    return sortedUsers;
}

//MARK: - QMContactListServiceDelegate

- (void)contactListService:(QMContactListService *)__unused contactListService contactListDidChange:(QBContactList *)__unused contactList {
    
    [self.delegate searchDataProviderDidFinishDataFetching:self];
}

@end
