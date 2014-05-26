//
//  NSString+ArrayToString.m
//  Q-municate
//
//  Created by Igor Alefirenko on 26/05/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "NSArray+ArrayToString.h"

@implementation NSArray (ArrayToString)

- (NSString *)stringFromArray
{
    NSMutableString *newString = [NSMutableString new];
    for (NSString *string in self) {
        [newString appendString:string];
        [newString appendString:@","];
    }
    [newString deleteCharactersInRange:NSMakeRange(newString.length - 1, 1)];
    
    return [newString copy];
}

@end
