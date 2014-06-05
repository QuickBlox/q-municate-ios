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
@property (strong, nonatomic) dispatch_queue_t queue;
@property (strong, nonatomic) NSManagedObjectContext *context;

@end

@implementation QMDBStorage


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
        self.queue = dispatch_queue_create("com.qmunicate.DBQueue", NULL);
        self.stack = stack;
    }
    
    return self;
}

- (NSManagedObjectContext *)context {
    if (!_context) {
        _context = [NSManagedObjectContext MR_confinementContextWithParent:self.stack.context];
    }
    return _context;
}

- (void)async:(QMDBContextBlock)block {
    
    dispatch_async(self.queue, ^{
        block(self.context);
    });
}

- (void)sync:(QMDBContextBlock)block {
    
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
