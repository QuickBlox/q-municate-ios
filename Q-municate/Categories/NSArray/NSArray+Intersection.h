//
//  NSArray+Intersection.h
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 4/7/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (Intersection)

/**
 *  Returns a Boolean value that indicates whether at least one object in the receiving array is also present in another given array.
 *
 *  @param array The array with which to compare the receiving array.
 *
 *  @discussion Object equality is tested using isEqual:.
 *
 *  @return YES if at least one object in the receiving array is also present in current array, otherwise NO.
 */
- (BOOL)containsObjectFromArray:(NSArray *)array;

@end
