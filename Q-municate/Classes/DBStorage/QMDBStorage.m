//
//  QMDBStorage.m
//  Q-municate
//
//  Created by Andrey on 04.06.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMDBStorage.h"



@interface QMDBStorage ()

@property (strong, nonatomic) MagicalRecordStack *stack;
@property (strong, nonatomic, readonly) NSManagedObjectContext *context;
@property (strong, nonatomic) dispatch_queue_t queue;

@end

@implementation QMDBStorage

@dynamic context;

static QMDBStorage *storage = nil;

+ (void)setupWithName:(NSString *)name {
    
    storage = nil;
    
    NSString* fileName = [NSString stringWithFormat:@"%@.sqlite", name];
    
    [MagicalRecord cleanUp];
    MagicalRecordStack *stack = [MagicalRecord setupSQLiteStackWithStoreNamed:fileName];
    
    storage = [[QMDBStorage alloc] initWithStack:stack];
}

+ (QMDBStorage *)shared {
    
    NSAssert(storage, @"You must first perform @selector(setupWithName:)");
    return storage;
}

- (instancetype)initWithStack:(MagicalRecordStack *)stack {
    
    self = [super init];

    if (self) {
        _queue = dispatch_queue_create("com.qmunicate.DBQueue", NULL);
    }
    
    return self;
}

- (NSManagedObjectContext *)context {
    
    return [NSManagedObjectContext MR_context];
}

- (void)async:(QMDBContextBlock)block {
    
    dispatch_async(self.queue, ^{
        NSLog(@"async context:%@", [self.context MR_workingName]);
        block(self.context);
    });
}

- (void)sync:(QMDBContextBlock)block {
    
    NSLog(@"sync context:%@", [self.context MR_workingName]);
    dispatch_sync(self.queue, ^{
        block(self.context);
    });
}

- (void)save:(QMDBFinishBlock)completion {
    
    [self async:^(NSManagedObjectContext *context) {
        
        [context MR_saveToPersistentStoreAndWait];
        if(completion)
            DO_AT_MAIN(completion());
    }];
}

@end

@implementation NSObject (QMDBStorage)

@dynamic dbStorage;

- (QMDBStorage *)dbStorage {
    
    return [QMDBStorage shared];
}

@end
