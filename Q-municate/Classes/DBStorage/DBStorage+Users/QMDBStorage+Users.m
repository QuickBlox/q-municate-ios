//
//  QMDBStorage+Users.m
//  Q-municate
//
//  Created by Andrey on 04.06.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMDBStorage+Users.h"
#import "CDUser+QBUUser.h"


@interface QMDBStorage ()

<NSFetchedResultsControllerDelegate>

@end

@implementation QMDBStorage (Users)

#pragma mark - Public methods

- (void)cachedQbUsers:(QMDBCollectionBlock)qbUsers {
    
    __weak __typeof(self)weakSelf = self;
    [self async:^(NSManagedObjectContext *context) {

        NSArray *result = nil;
        NSArray *cdUsers = [CDUser MR_findAll];
        result = (cdUsers.count == 0) ? @[] : [weakSelf qbUsersWithcdUsers:cdUsers];
        DO_AT_MAIN(qbUsers(result));
        
    }];
}

- (void)cacheUsers:(NSArray *)users finish:(QMDBFinishBlock)finish {
    
    __weak __typeof(self)weakSelf = self;
    
    [self async:^(NSManagedObjectContext *context) {
        [weakSelf mergeQBUsers:users inContext:context];
    }];
}

#pragma mark - Private methods

- (NSArray *)qbUsersWithcdUsers:(NSArray *)cdUsers {
    
    NSMutableArray *qbUsers = [NSMutableArray arrayWithCapacity:cdUsers.count];
    
    for (CDUser *user in cdUsers) {
        QBUUser *qbUser = [user toQBUUser];
        [qbUsers addObject:qbUser];
    }
    
    return qbUsers;
}

- (void)mergeQBUsers:(NSArray *)qbUsers inContext:(NSManagedObjectContext *)context {
    
    [self cachedQbUsers:^(NSArray *collection) {
        
        
        
    }];
}

@end
