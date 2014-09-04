//
//  QMDBStorage.m
//  Q-municate
//
//  Created by Andrey Ivanov on 04.06.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMDBStorage.h"

@interface QMDBStorage ()

@property (strong, nonatomic) MagicalRecordStack *stack;
@property (strong, nonatomic) dispatch_queue_t queue;
@property (strong, nonatomic) NSManagedObjectContext *context;
@property (strong, nonatomic) NSString *storeName;

@end

@implementation QMDBStorage

static QMDBStorage *storage = nil;

NSString *StoreFileName(NSString *name) {
    
    NSString* fileName = [NSString stringWithFormat:@"%@.sqlite", name];
    return fileName;
}

+ (void)setupWithName:(NSString *)name {
    
    storage = nil;
    
    [MagicalRecord cleanUp];
    
    MagicalRecordStack *stack = [MagicalRecord setupAutoMigratingStackWithSQLiteStoreNamed:StoreFileName(name)];
    storage = [[QMDBStorage alloc] initWithStack:stack storeName:name];
}

+ (QMDBStorage *)shared {
    
    NSAssert(storage, @"You must first perform @selector(setupWithName:)");
    return storage;
}

+ (NSURL *)storeUrlWithName:(NSString *)name {
    
    NSURL *storeUrl = [NSPersistentStore MR_fileURLForStoreNameIfExistsOnDisk:StoreFileName(name)];
    return storeUrl;
}

+ (void)cleanDBWithName:(NSString *)name {
    
    [MagicalRecord cleanUp];
    
    NSURL *storeUrl = [self storeUrlWithName:name];
    
    if (storeUrl) {
        
        NSError *error = nil;
        if(![[NSFileManager defaultManager] removeItemAtURL:storeUrl error:&error]) {
            ILog(@"An error has occurred while deleting %@", storeUrl);
            ILog(@"Error description: %@", error.description);
        } else {
            ILog(@"Clear %@ - Done!", storeUrl);
        }
    }
}

- (instancetype)initWithStack:(MagicalRecordStack *)stack storeName:(NSString *)storeName {
    
    self = [super init];
    
    if (self) {
        
        self.queue = dispatch_queue_create("com.qmunicate.DBQueue", NULL);
        self.stack = stack;
        self.storeName = storeName;
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
