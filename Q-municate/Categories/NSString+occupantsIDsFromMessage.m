//
//  NSString+occupantsIDsFromMessage.m
//  Q-municate
//
//  Created by Igor Alefirenko on 18.08.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "NSString+occupantsIDsFromMessage.h"

@implementation NSString (occupantsIDsFromMessage)

- (NSArray *)occupantsIDs
{
    NSMutableArray *numbsArray = [[NSMutableArray alloc] init];
    NSArray *array = [self componentsSeparatedByString:@","];
    for (NSString *ID in array) {
        [numbsArray addObject:@(ID.intValue)];
    }
    return [numbsArray copy];
}

@end
