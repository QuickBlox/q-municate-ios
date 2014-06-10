//
//  QMDBStorage+Dialogs.m
//  Q-municate
//
//  Created by Andrey on 04.06.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMDBStorage+Dialogs.h"
#import "ModelIncludes.h"
#import "QMDBStorage+Messages.h"

@implementation QMDBStorage (Dialogs)

- (void)cacheQBDialogs:(NSArray *)dialogs finish:(QMDBFinishBlock)finish {
    
    __weak __typeof(self)weakSelf = self;
    
    [self async:^(NSManagedObjectContext *context) {
        
        [weakSelf mergeQBChatDialogs:dialogs inContext:context finish:finish];
        
    }];
}

- (void)cachedQBChatDialogs:(QMDBCollectionBlock)qbDialogs {
    
    [self async:^(NSManagedObjectContext *context) {
        NSArray *allDialogs = [self allQBChatDialogsInContext:context];
        DO_AT_MAIN(qbDialogs(allDialogs));
    }];
}


- (NSArray *)allQBChatDialogsInContext:(NSManagedObjectContext *)context {
    
    NSArray *cdChatDialogs = [CDDialog MR_findAllInContext:context];
    NSArray *result = (cdChatDialogs.count == 0) ? @[] : [self qbChatDialogsWithcdDialogs:cdChatDialogs];
    
    return result;
}

- (NSArray *)qbChatDialogsWithcdDialogs:(NSArray *)cdDialogs {
    
    NSMutableArray *qbChatDialogs = [NSMutableArray arrayWithCapacity:cdDialogs.count];
    
    for (CDDialog *dialog in cdDialogs) {
        QBChatDialog *qbUser = [dialog toQBChatDialog];
        [qbChatDialogs addObject:qbUser];
    }
    
    return qbChatDialogs;
}

- (void)mergeQBChatDialogs:(NSArray *)qbChatDialogs inContext:(NSManagedObjectContext *)context finish:(QMDBFinishBlock)finish {
    
    NSArray *allDialogs = [CDDialog MR_findAllInContext:context];
    
    NSMutableArray *toInsert = [NSMutableArray array];
    NSMutableArray *toUpdate = [NSMutableArray array];
    NSMutableArray *toDelete = [NSMutableArray arrayWithArray:allDialogs];
    
    //Update/Insert/Delete
    
    for (QBChatDialog *dialog in qbChatDialogs) {
        
        NSInteger idx = [allDialogs indexOfObject:dialog];
        
        if (idx == NSNotFound) {
            
            QBChatDialog *dialogToUpdate = nil;
            
            for (QBChatDialog *candidateToUpdate in allDialogs) {
                
                if (candidateToUpdate.ID == dialog.ID) {
                    
                    dialogToUpdate = dialog;
                    [toDelete removeObject:candidateToUpdate];
                    
                    break;
                }
            }
            
            if (toUpdate) {
                [toUpdate addObject:dialogToUpdate];
            } else {
                [toInsert addObject:dialog];
            }
            
        } else {
            [toDelete removeObject:dialog];
        }
    }
    
    __weak __typeof(self)weakSelf = self;
    [self async:^(NSManagedObjectContext *context) {
        
        if (toUpdate.count != 0) {
            [weakSelf updateQBChatDialogs:toUpdate inContext:context];
        }
        
        if (toInsert.count != 0) {
            [weakSelf insertQBChatDialogs:toInsert inContext:context];
        }
        
        if (toDelete.count != 0) {
            [weakSelf deleteQBChatDialogs:toDelete inContext:context];
        }
        
        NSLog(@"Dialogs in cahce %d", allDialogs.count);
        NSLog(@"Dialogs to insert %d", toInsert.count);
        NSLog(@"Dialogs to update %d", toUpdate.count);
        NSLog(@"Dialogs to delete %d", toDelete.count);
        
        [weakSelf save:finish];
    }];
}

- (void)insertQBChatDialogs:(NSArray *)qbChatDialogs inContext:(NSManagedObjectContext *)context {
    
    for (QBChatDialog *qbChatDialog in qbChatDialogs) {
        CDDialog *dialogToInsert = [CDDialog MR_createEntityInContext:context];
        [dialogToInsert updateWithQBChatDialog:qbChatDialog];
    }
}

- (void)deleteQBChatDialogs:(NSArray *)qbChatDialogs inContext:(NSManagedObjectContext *)context {
    
    
    for (QBChatDialog *qbChatDialog in qbChatDialogs) {
        CDDialog *dialogToDelete = [CDDialog MR_findFirstWithPredicate:IS(@"uniqueId", qbChatDialog.ID)
                                                             inContext:context];
        [dialogToDelete MR_deleteEntityInContext:context];
    }
}

- (void)updateQBChatDialogs:(NSArray *)qbChatDialogs inContext:(NSManagedObjectContext *)context {
    
    for (QBChatDialog *qbChatDialog in qbChatDialogs) {
        CDDialog *dialogToUpdate = [CDDialog MR_findFirstWithPredicate:IS(@"uniqueId", qbChatDialog.ID)
                                                             inContext:context];
        [dialogToUpdate updateWithQBChatDialog:qbChatDialog];
    }
}


@end
