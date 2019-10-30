//
//  NSArray+Intersection.m
//  Q-municate
//
//  Created by Injoit on 4/7/16.
//  Copyright © 2016 QuickBlox. All rights reserved.
//

#import "NSArray+Intersection.h"

@implementation NSArray (Intersection)

- (BOOL)qm_containsObjectFromArray:(NSArray *)array {
    
    NSMutableSet *baseSet = [NSMutableSet setWithArray:self];
    NSMutableSet *fromSet = [NSMutableSet setWithArray:array];
    
    return [baseSet intersectsSet:fromSet];
}

@end
