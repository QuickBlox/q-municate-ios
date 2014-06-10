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

- (void)cacheQBChatMessages:(NSArray *)messages finish:(QMDBFinishBlock)finish {
    
//    __weak __typeof(self)weakSelf = self;
    
    [self async:^(NSManagedObjectContext *context) {
//        [weakSelf insertNewMessages:messages inContext:context];
    }];
}

- (void)insertNewMessages:(NSArray *)messages inContext:(NSManagedObjectContext *)context {
    
    for (QBChatMessage *chatMessage in messages) {
        
        CDMessages *message = [CDMessages MR_createEntityInContext:context];
        [message updateWithQBChatMessage:chatMessage];
    }
}

- (void)cachedQBChatMessagesWithDialog:(id)dialog  qbMessages:(QMDBCollectionBlock)qbMessages {
    
    [self async:^(NSManagedObjectContext *context) {
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@""];
        NSArray *messages = [CDMessages MR_findAllSortedBy:@"datetime"
                                                 ascending:NO
                                             withPredicate:predicate
                                                 inContext:context];
        DO_AT_MAIN(qbMessages(messages));
        
    }];
    

}

@end
