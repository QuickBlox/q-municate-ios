//
//  NSString+HasText.m
//  Q-municate
//
//  Created by Andrey Ivanov on 20.06.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "NSString+HasText.h"

@implementation NSString (HasText)

- (NSString *)stringByTrimingWhitespace {
    
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (BOOL)hasText {
    
    NSString *trimingStr = [self stringByTrimingWhitespace];
    BOOL hasText = trimingStr.length > 0;
    
    return hasText;
}

@end
