//
//  QMDBStorage.h
//  Q-municate
//
//  Created by Andrey on 04.06.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DO_AT_MAIN(x) dispatch_async(dispatch_get_main_queue(), ^{ x; });

typedef void(^QMDBCollectionBlock)(NSArray *collection);
typedef void(^QMDBContextBlock)(NSManagedObjectContext *context);
typedef void(^QMDBFinishBlock)(void);

@interface QMDBStorage : NSObject	

/**
 * @brief Load CoreData file
 * @param name - filename with extension
 */

+ (void)setupWithName:(NSString *)name;

/**
 * @brief Clean data base for name
 */

+ (void)cleanDBWithName:(NSString *)name;

/**
 * @brief Perform operation in CoreData thread
 */

- (void)async:(QMDBContextBlock)block;
- (void)sync:(QMDBContextBlock)block;

/**
 * @brief Save to persistent store
 */

- (void)save:(QMDBFinishBlock)completion;

@end

@interface NSObject (QMDBStorage)

@property (strong, nonatomic, readonly) QMDBStorage *dbStorage;

@end