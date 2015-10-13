//
//  QMCDRecord+Actions.h
//
//  Created by Injoit on 2/24/11.
//  Copyright (c) 2015 Quickblox Team. All rights reserved.
//

#import "QMCDRecordStack.h"
#import "NSManagedObjectContext+QMCDRecord.h"
#import "NSManagedObjectContext+QMCDSaves.h"

dispatch_queue_t QM_saveQueue(void);


@interface QMCDRecordStack (Actions)

/* For all background saving operations. These calls will be sent to a different thread/queue.
 */
- (void) saveWithBlock:(void(^)(NSManagedObjectContext *localContext))block;
- (void) saveWithBlock:(void(^)(NSManagedObjectContext *localContext))block completion:(MRSaveCompletionHandler)completion;
- (void) saveWithBlock:(void (^)(NSManagedObjectContext *))block identifier:(NSString *)contextWorkingName completion:(MRSaveCompletionHandler)completion;

- (void) saveWithIdentifier:(NSString *)identifier block:(void(^)(NSManagedObjectContext *))block;


/**
 *  Synchronously saves the default managed object context (if there is one) and any parent contexts.
 *
 *  @param block Make changes to CoreData objects in this block using the passed in localContext. The block will be performed on a background queue, and once complete, the context will be saved.
 *
 *  @return Success state of the save operation
 */
- (BOOL) saveWithBlockAndWait:(void(^)(NSManagedObjectContext *localContext))block;

/**
 *  @method saveWithBlockAndWait: error:
 *
 *  Synchronously saves the default managed object context (if there is one) and any parent contexts.
 *
 *  @param block Make changes to CoreData objects in this block using the passed in localContext. The block will be performed on a background queue, and once complete, the context will be saved.
 *  @param error Pass in an NSError by reference to receive any errors encountered during the save.
 *
 *  @return Whether the save was successful
 */
- (BOOL) saveWithBlockAndWait:(void(^)(NSManagedObjectContext *localContext))block error:(NSError **)error;

@end
