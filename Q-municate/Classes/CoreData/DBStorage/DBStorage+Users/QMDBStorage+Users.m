//
//  QMDBStorage+Users.m
//  Q-municate
//
//  Created by Andrey on 04.06.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMDBStorage+Users.h"
#import "ModelIncludes.h"

@interface QMDBStorage ()

<NSFetchedResultsControllerDelegate>

@end

@implementation QMDBStorage (Users)

#pragma mark - Public methods

- (void)cachedQbUsers:(QMDBCollectionBlock)qbUsers {
    
    NSArray *allUsers = [self allUsers];
    [self async:^(NSManagedObjectContext *context) {
        
        DO_AT_MAIN(qbUsers(allUsers));
        
    }];
}

- (void)cacheUsers:(NSArray *)users finish:(QMDBFinishBlock)finish {
    
    __weak __typeof(self)weakSelf = self;
    
    [self async:^(NSManagedObjectContext *context) {
        [weakSelf mergeQBUsers:users inContext:context finish:finish];
    }];
}

#pragma mark - Private methods

- (NSArray *)allUsers {
    
    NSArray *cdUsers = [CDUsers MR_findAll];
    NSArray *result = (cdUsers.count == 0) ? @[] : [self qbUsersWithcdUsers:cdUsers];
    
    return result;
}

- (NSArray *)qbUsersWithcdUsers:(NSArray *)cdUsers {
    
    NSMutableArray *qbUsers = [NSMutableArray arrayWithCapacity:cdUsers.count];
    
    for (CDUsers *user in cdUsers) {
        QBUUser *qbUser = [user toQBUUser];
        [qbUsers addObject:qbUser];
    }
    
    return qbUsers;
}

- (void)mergeQBUsers:(NSArray *)qbUsers inContext:(NSManagedObjectContext *)context finish:(QMDBFinishBlock)finish {
    
    NSArray *allUsers = [self allUsers];
    
    NSMutableArray *toInsert = [NSMutableArray array];
    NSMutableArray *toDelete = [NSMutableArray array];
    NSMutableArray *toUpdate = [NSMutableArray array];
    
    for (QBUUser *user in qbUsers) {
        
        NSInteger idx = [allUsers indexOfObject:user];
        
        if (idx == NSNotFound) {
            
            QBUUser *toUpdateUser = nil;
            
            for (QBUUser *candidateToUpdate in allUsers) {
                
                if (candidateToUpdate.externalUserID == user.externalUserID) {
                    toUpdateUser = candidateToUpdate;
                    break;
                }
            }
            
            if (toUpdateUser) {
                
                [toUpdate addObject:toUpdateUser];
                
            } else {
                [toInsert addObject:user];
            }
        }
    }
    
    __weak __typeof(self)weakSelf = self;
    [self async:^(NSManagedObjectContext *context) {
        
        if (toInsert.count != 0) {
            [weakSelf insertQBUsers:toInsert inContext:context];
            NSLog(@"new users -%d ", toInsert.count);
        }
        
        if (toDelete.count != 0) {
            [weakSelf deleteQBUsers:toDelete inContext:context];
            NSLog(@"deleted users -%d ", toDelete.count);
        }
        
        [weakSelf save:finish];
    }];
}

- (void)insertQBUsers:(NSArray *)qbUsers inContext:(NSManagedObjectContext *)context {
    
    for (QBUUser *qbUser in qbUsers) {
        CDUsers *user = [CDUsers MR_createEntityInContext:context];
        [user updateWithQBUser:qbUser];
    }
}

- (void)deleteQBUsers:(NSArray *)qbUsers inContext:(NSManagedObjectContext *)context {
    
    for (QBUUser *qbUser in qbUsers) {
        CDUsers *user = [CDUsers MR_createEntityInContext:context];
        [user updateWithQBUser:qbUser];
    }
}

- (void)updateQBUsers:(NSArray *)qbUsers inContext:(NSManagedObjectContext *)context {
    
    for (QBUUser *qbUser in qbUsers) {
        CDUsers *user = [CDUsers MR_createEntityInContext:context];
        [user updateWithQBUser:qbUser];
    }
}

@end
