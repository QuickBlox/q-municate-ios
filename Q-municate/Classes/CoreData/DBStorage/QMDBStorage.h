//
//  QMDBStorage.h
//  Q-municate
//
//  Created by Andrey on 04.06.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

#define CONTAINS(attrName, attrVal) [NSPredicate predicateWithFormat:@"self.%K CONTAINS %@", attrName, attrVal]
#define LIKE(attrName, attrVal) [NSPredicate predicateWithFormat:@"%K like %@", attrName, attrVal]
#define LIKE_C(attrName, attrVal) [NSPredicate predicateWithFormat:@"%K like[c] %@", attrName, attrVal]
#define IS(attrName, attrVal) [NSPredicate predicateWithFormat:@"%K == %@", attrName, attrVal]

#define DO_AT_MAIN(x) dispatch_async(dispatch_get_main_queue(), ^{ x; });

typedef void(^QMDBCollectionBlock)(NSArray *collection);
typedef void(^QMDBContextBlock)(NSManagedObjectContext *context);
typedef void(^QMDBFinishBlock)(void);

@interface QMDBStorage : NSObject	

/**
 * @brief Load CoreData(Sqlite) file
 * @param name - filename
 */

+ (void)setupWithName:(NSString *)name;

/**
 * @brief Clean data base with store name
 */

+ (void)cleanDBWithName:(NSString *)name;

/**
 * @brief Perform operation in CoreData thread
 */

- (void)async:(QMDBContextBlock)block;
- (void)sync:(QMDBContextBlock)block;

/**
 * @brief Save to persistent store (async)
 */

- (void)save:(QMDBFinishBlock)completion;

@end

@interface NSObject (QMDBStorage)

@property (strong, nonatomic, readonly) QMDBStorage *dbStorage;

@end