//
//  QMDBStorage+Messages.m
//  Q-municate
//
//  Created by Andrey on 04.06.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMDBStorage+Messages.h"
#import "ModelIncludes.h"

@implementation QMDBStorage (Messages)

- (void)cacheQBChatMessages:(NSArray *)messages withDialogId:(NSString *)dialogId finish:(QMDBFinishBlock)finish {
    
    __weak __typeof(self)weakSelf = self;
    START_LOG_TIME
    [self async:^(NSManagedObjectContext *context) {
        [weakSelf mergeQBChatHistoryMessages:messages withDialogId:dialogId inContext:context finish:^{
            END_LOG_TIME
            finish();
        }];
    }];
}

- (void)cachedQBChatMessagesWithDialogId:(NSString *)dialogId qbMessages:(QMDBCollectionBlock)qbMessages {
    
    [self async:^(NSManagedObjectContext *context) {
        
        NSArray *messages = [CDMessages MR_findAllSortedBy:kCDMessageDatetimePath
                                                 ascending:NO
                                             withPredicate:IS(@"dialogId", dialogId)
                                                 inContext:context];
        NSArray *result = [self qbChatHistoryMessagesWithcdMessages:messages];
        
        DO_AT_MAIN(qbMessages(result));
        
    }];
}

- (void)insertNewMessages:(NSArray *)messages inContext:(NSManagedObjectContext *)context {
    
    for (QBChatHistoryMessage *chatMessage in messages) {
        
        CDMessages *message = [CDMessages MR_createEntityInContext:context];
        [message updateWithQBChatHistoryMessage:chatMessage];
    }
}

- (NSArray *)allQBChatHistoryMessagesWithDialogId:(NSString *)dialogId InContext:(NSManagedObjectContext *)context {
    
    NSArray *cdChatHistoryMessages = [CDMessages MR_findAllSortedBy:kCDMessageDatetimePath
                                                          ascending:NO
                                                      withPredicate:IS(@"dialogId", dialogId)
                                                          inContext:context];
    
    NSArray *result = (cdChatHistoryMessages.count == 0) ? @[] : [self qbChatHistoryMessagesWithcdMessages:cdChatHistoryMessages];
    
    return result;
}

- (NSArray *)qbChatHistoryMessagesWithcdMessages:(NSArray *)cdMessages {
    
    NSMutableArray *qbChatHistoryMessages = [NSMutableArray arrayWithCapacity:cdMessages.count];
    
    for (CDMessages *message in cdMessages) {
        QBChatHistoryMessage *qbChatHistoryMessage = [message toQBChatHistoryMessage];
        [qbChatHistoryMessages addObject:qbChatHistoryMessage];
    }
    
    return qbChatHistoryMessages;
}

- (void)mergeQBChatHistoryMessages:(NSArray *)qbChatHistoryMessages
                      withDialogId:(NSString *)dialogId
                         inContext:(NSManagedObjectContext *)context
                            finish:(QMDBFinishBlock)finish {
    
    NSArray *allQBChatHistoryMessagesInCache = [self allQBChatHistoryMessagesWithDialogId:dialogId
                                                                                InContext:context];
    
    NSMutableArray *toInsert = [NSMutableArray array];
    NSMutableArray *toUpdate = [NSMutableArray array];
    NSMutableArray *toDelete = [NSMutableArray arrayWithArray:allQBChatHistoryMessagesInCache];
    
    //Update/Insert/Delete
    
    for (QBChatHistoryMessage *historyMessage in qbChatHistoryMessages) {
        
        NSInteger idx = [allQBChatHistoryMessagesInCache indexOfObject:historyMessage];
        
        if (idx == NSNotFound) {
            
            QBChatHistoryMessage *chatHistoryMessageToUpdate = nil;
            
            for (QBChatHistoryMessage *candidateToUpdate in allQBChatHistoryMessagesInCache) {
                
                if ([candidateToUpdate.ID isEqual: historyMessage.ID]) {
                    
                    chatHistoryMessageToUpdate = historyMessage;
                    [toDelete removeObject:candidateToUpdate];
                    
                    break;
                }
            }
            
            if (chatHistoryMessageToUpdate) {
                [toUpdate addObject:chatHistoryMessageToUpdate];
            } else {
                [toInsert addObject:historyMessage];
            }
            
        } else {
            [toDelete removeObject:historyMessage];
        }
    }
    
    __weak __typeof(self)weakSelf = self;
    [self async:^(NSManagedObjectContext *context) {
        
        if (toUpdate.count != 0) {
            [weakSelf updateQBChatHistoryMessages:toUpdate inContext:context];
        }
        
        if (toInsert.count != 0) {
            [weakSelf insertQBChatHistoryMessages:toInsert inContext:context];
        }
        
        if (toDelete.count != 0) {
            [weakSelf deleteQBChatHistoryMessages:toDelete inContext:context];
        }
        NSLog(@"/////////////////////////////////");
        NSLog(@"Chat history in cahce %d objects by id %@", allQBChatHistoryMessagesInCache.count, dialogId);
        NSLog(@"Messages to insert %d", toInsert.count);
        NSLog(@"Messages to update %d", toUpdate.count);
        NSLog(@"Messages to delete %d", toDelete.count);
        NSLog(@"/////////////////////////////////");
        [weakSelf save:finish];
    }];
}

- (void)insertQBChatHistoryMessages:(NSArray *)qbChatHistoryMessages inContext:(NSManagedObjectContext *)context {
    
    for (QBChatHistoryMessage *qbChatHistoryMessage in qbChatHistoryMessages) {
        CDMessages *messageToInsert = [CDMessages MR_createEntityInContext:context];
        [messageToInsert updateWithQBChatHistoryMessage:qbChatHistoryMessage];
    }
}

- (void)deleteQBChatHistoryMessages:(NSArray *)qbChatHistoryMessages inContext:(NSManagedObjectContext *)context {
    
    
    for (QBChatHistoryMessage *qbChatHistoryMessage in qbChatHistoryMessages) {
        CDMessages *messageToDelete = [CDMessages MR_findFirstWithPredicate:IS(@"uniqueId", qbChatHistoryMessage.ID)
                                                             inContext:context];
        [messageToDelete MR_deleteEntityInContext:context];
    }
}

- (void)updateQBChatHistoryMessages:(NSArray *)qbChatHistoryMessages inContext:(NSManagedObjectContext *)context {
    
    for (QBChatHistoryMessage *qbChatHistoryMessage in qbChatHistoryMessages) {
        CDMessages *messageToUpdate = [CDMessages MR_findFirstWithPredicate:IS(@"uniqueId", qbChatHistoryMessage.ID)
                                                             inContext:context];
        [messageToUpdate updateWithQBChatHistoryMessage:qbChatHistoryMessage];
    }
}

@end
