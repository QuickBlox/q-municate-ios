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

@interface QMGlobalSearchDataProvider ()

@property (strong, nonatomic) BFCancellationTokenSource *globalSearchCancellationTokenSource;

@property (strong, nonatomic) NSTimer* timer;

@property (strong, nonatomic) QBGeneralResponsePage *responsePage;
@property (assign, nonatomic) BOOL shouldLoadMore;
@property (strong, nonatomic) NSString *cachedSearchText;

@end

@implementation QMGlobalSearchDataProvider

- (instancetype)init {
    
    self = [super init];
    
    if (self) {
        
        _responsePage = [QBGeneralResponsePage responsePageWithCurrentPage:1 perPage:kQMUsersPageLimit];
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
        [self callDelegate];
        return;
    }
    
    if (self.globalSearchCancellationTokenSource) {
        // cancel existing task if in progress
        [self.globalSearchCancellationTokenSource cancel];
    }
    
    if (![searchText isEqualToString:self.cachedSearchText]) {
        
        self.cachedSearchText = searchText.copy;
        self.responsePage.currentPage = 1;
    }
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:kQMGlobalSearchTimeInterval
                                                  target:self
                                                selector:@selector(globalSearch)
                                                userInfo:nil
                                                 repeats:NO];
}

- (void)globalSearch {
    
    self.globalSearchCancellationTokenSource = [BFCancellationTokenSource cancellationTokenSource];
    
    @weakify(self);
    [[[QMCore instance].usersService searchUsersWithFullName:self.cachedSearchText page:self.responsePage] continueWithBlock:^id _Nullable(BFTask<NSArray<QBUUser *> *> * _Nonnull task) {
        @strongify(self);
        if (task.isCompleted) {
            
            self.globalSearchCancellationTokenSource = nil;
            
            if (task.result.count < kQMUsersPageLimit) {
                
                self.shouldLoadMore = NO;
            }
            else {
                
                self.shouldLoadMore = YES;
            }
            
            NSArray *sortedUsers = [self sortUsersByFullname:task.result];
            
            if (self.responsePage.currentPage > 1) {
                
                [self.dataSource addItems:sortedUsers];
            }
            else {
                
                [self.dataSource replaceItems:sortedUsers];
            }
            
            [self callDelegate];
        }
        
        return nil;
    } cancellationToken:self.globalSearchCancellationTokenSource.token];
}

- (void)callDelegate {
    
    if ([self.delegate respondsToSelector:@selector(searchDataProviderDidFinishDataFetching:)]) {
        
        [self.delegate searchDataProviderDidFinishDataFetching:self];
    }
}

#pragma mark - Pagination

- (void)nextPage {
    
    if (self.shouldLoadMore) {
        
        self.responsePage.currentPage++;
        [self performSearch:self.cachedSearchText];
    }
}

#pragma mark - Helpers

- (NSArray *)sortUsersByFullname:(NSArray *)users
{
    NSSortDescriptor *sorter = [[NSSortDescriptor alloc]
                                initWithKey:@"fullName"
                                ascending:YES
                                selector:@selector(localizedCaseInsensitiveCompare:)];
    NSArray *sortedUsers = [users sortedArrayUsingDescriptors:@[sorter]];
    
    return sortedUsers;
}

@end
