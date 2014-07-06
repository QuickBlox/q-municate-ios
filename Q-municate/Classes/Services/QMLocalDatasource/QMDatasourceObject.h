//
//  QMDatasourceObject.h
//  Qmunicate
//
//  Created by Andrey on 06.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol QBDatasourceObject<NSObject>

/*!
 @method
 @abstract
 Returns the number of properties on this `QBDatasourceObject`.
 */
- (NSUInteger)count;
/*!
 @method
 @abstract
 Returns a property on this `QBDatasourceObject`.
 
 @param aKey        name of the property to return
 */
- (id)objectForKey:(id)aKey;
/*!
 @method
 @abstract
 Returns an enumerator of the property naems on this `QBDatasourceObject`.
 */
- (NSEnumerator *)keyEnumerator;
/*!
 @method
 @abstract
 Removes a property on this `QBDatasourceObject`.
 
 @param aKey        name of the property to remove
 */
- (void)removeObjectForKey:(id)aKey;
/*!
 @method
 @abstract
 Sets the value of a property on this `QBDatasourceObject`.
 
 @param anObject    the new value of the property
 @param aKey        name of the property to set
 */
- (void)setObject:(id)anObject forKey:(id)aKey;

@end

@interface QMDatasourceObject : NSDictionary <QBDatasourceObject>

@end
