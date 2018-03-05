//
//  NSPersistentStoreCoordinator+QMCDRecord.h
//
//  Created by Injoit on 3/11/10.
//  Copyright (c) 2015 Quickblox Team. All rights reserved.
//

#import "QMCDRecord.h"
#import "NSPersistentStore+QMCDRecord.h"

extern NSString * const QMCDRecordShouldDeletePersistentStoreOnModelMismatchKey;
extern NSString * const QMCDRecordShouldMigrateKey;
extern NSString * const QMCDRecordShouldDeleteOldDBKey;
extern NSString * const QMCDRecordTargetURLKey;
extern NSString * const QMCDRecordSourceURLKey;
extern NSString * const QMCDRecordGroupURLKey;

@interface NSPersistentStoreCoordinator (QMCDRecord)

- (NSPersistentStore *)QM_addSqliteStoreAtURL:(NSURL *)url withOptions:(NSDictionary *__autoreleasing)options;
- (NSPersistentStore *)QM_addSqliteStoreNamed:(id)storeFileName withOptions:(__autoreleasing NSDictionary *)options;

@end
