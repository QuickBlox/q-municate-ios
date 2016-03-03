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

@property (weak, nonatomic) BFTask *globalSearchTask;
@property (strong, nonatomic) BFCancellationTokenSource *globalSearchCancellationTokenSource;

@property (strong, nonatomic) NSTimer* timer;
@property (assign, nonatomic) NSUInteger currentPage;
@property (assign, nonatomic) BOOL shouldLoadMore;

@end

@implementation QMGlobalSearchDataProvider

- (instancetype)init {
    
    self = [super init];
    
    if (self) {
        
        _globalSearchCancellationTokenSource = [BFCancellationTokenSource cancellationTokenSource];
    }
    
    return self;
}

- (void)performSearch:(NSString *)searchText {
    
    if (![self.dataSource conformsToProtocol:@protocol(QMGlobalSearchDataSourceProtocol)]) {
        
        return;
    }
    
    if (searchText.length < kQMGlobalSearchCharsMin) {
        
        [self.dataSource.items removeAllObjects];
        [self callDelegate];
        return;
    }
    
    if (self.globalSearchTask && !self.globalSearchTask.isCompleted) {
        // cancel existing task if in progress
        [self.globalSearchCancellationTokenSource cancel];
        self.globalSearchTask = nil;
    }
    
    QBGeneralResponsePage *page = [QBGeneralResponsePage responsePageWithCurrentPage:self.currentPage perPage:kQMUsersPageLimit];
    
    @weakify(self);
    self.globalSearchTask = [[[QMCore instance].usersService searchUsersWithFullName:searchText page:page] continueWithBlock:^id _Nullable(BFTask<NSArray<QBUUser *> *> * _Nonnull task) {
        @strongify(self);
        if (task.isCompleted) {
            
            if (task.result.count < kQMUsersPageLimit) {
                
                self.shouldLoadMore = NO;
            }
            else {
                
                self.shouldLoadMore = YES;
            }
            
            NSArray *sortedUsers = [self sortUsersByFullname:task.result];
            
            if (self.currentPage > 1) {
                
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
