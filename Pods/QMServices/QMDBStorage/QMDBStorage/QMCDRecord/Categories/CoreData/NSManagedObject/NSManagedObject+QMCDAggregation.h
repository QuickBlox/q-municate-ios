//
//  NSManagedObject+QMCDAggregation.h
//  QMCD Record
//
//  Created by Injoit on 3/7/12.
//  Copyright (c) 2015 Quickblox Team. All rights reserved.
//

#import <CoreData/CoreData.h>

/**
 Category methods that make aggregating and counting managed objects easier.
 
 @since Available in v2.0 and later.
 */
@interface NSManagedObject (QMCDAggregation)

+ (NSNumber *)QM_numberOfEntitiesWithContext:(NSManagedObjectContext *)context;

+ (NSNumber *)QM_numberOfEntitiesWithPredicate:(NSPredicate *)searchTerm inContext:(NSManagedObjectContext *)context;

/**
 Count of entities for the current class in the supplied context.
 
 @param context Managed object context
 
 @return Count of entities
 
 @since Available in v2.0 and later.
 */
+ (NSUInteger)QM_countOfEntitiesWithContext:(NSManagedObjectContext *)context;

/**
 Count of entities for the current class matching the supplied predicate in the supplied context.
 
 @param predicate Predicate to evaluate objects against
 @param context   Managed object context
 
 @return Count of entities
 
 @since Available in v2.0 and later.
 */
+ (NSUInteger)QM_countOfEntitiesWithPredicate:(NSPredicate *)predicate
                                    inContext:(NSManagedObjectContext *)context;

/**
 Check that there is at least one entity matching the current class in the supplied context.
 
 @param context Managed object context
 
 @return `YES` if there is at least on entity, otherwise `NO`.
 
 @since Available in v2.0 and later.
 */
+ (BOOL)QM_hasAtLeastOneEntityInContext:(NSManagedObjectContext *)context;

- (id)QM_minValueFor:(NSString *)property;
- (id)QM_maxValueFor:(NSString *)property;

/**
 Supports aggregating values using a key-value collection operator that can be grouped by an attribute.
 See https://developer.apple.com/library/ios/documentation/cocoa/conceptual/KeyValueCoding/Articles/CollectionOperators.html for a list of valid collection operators.
 
 @param collectionOperator   Collection operator
 @param attributeName        Entity attribute to apply the collection operator to
 @param predicate            Predicate to filter results
 @param groupingKeyPath      Key path to group results by
 @param context              Context to perform the request in
 
 @return Results of the collection operator, filtered by the provided predicate and grouped by the provided key path
 
 @since Available in v2.3 and later.
 */
+ (NSArray *)QM_aggregateOperation:(NSString *)collectionOperator
                       onAttribute:(NSString *)attributeName
                     withPredicate:(NSPredicate *)predicate
                           groupBy:(NSString*)groupingKeyPath
                         inContext:(NSManagedObjectContext *)context;

- (id)QM_objectWithMinValueFor:(NSString *)property;
- (id)QM_objectWithMinValueFor:(NSString *)property
                     inContext:(NSManagedObjectContext *)context;

@end
