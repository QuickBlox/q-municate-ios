//
//  NSString+HasText.h
//  Qmunicate
//
//  Created by Andrey Ivanov on 20.06.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (HasText)
/**
 *  @return A copy of the receiver with all leading and trailing whitespace removed.
 */
- (NSString *)stringByTrimingWhitespace;
/**
 *  Determines whether or not the text view contains text after trimming white space
 *  from the front and back of its string.
 *
 *  @return `YES` if the string contains text, `NO` otherwise.
 */
@property (nonatomic, readonly) BOOL hasText;

@end
