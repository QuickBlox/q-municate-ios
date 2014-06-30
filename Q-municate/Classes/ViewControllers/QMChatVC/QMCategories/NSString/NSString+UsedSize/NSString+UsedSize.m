//
//  NSString+UsedSize.m
//  Q-municate
//
//  Created by Andrey on 13.06.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "NSString+UsedSize.h"

@implementation NSString (UsedSize)

- (CGSize)usedSizeForMaxWidth:(CGFloat)width font:(UIFont *)font withAttributes:(NSDictionary *)attributes {

    NSTextStorage *textStorage = [[NSTextStorage alloc] initWithString:self attributes:attributes];

    NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize: CGSizeMake(width, MAXFLOAT)];
    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
    
    [layoutManager addTextContainer:textContainer];
    [textStorage addLayoutManager:layoutManager];

    if (!attributes) {
        [textStorage addAttribute:NSFontAttributeName
                            value:font
                            range:NSMakeRange(0, textStorage.length)];
    }
    
    [textContainer setLineFragmentPadding:0.0];
    
    [layoutManager glyphRangeForTextContainer:textContainer];
    CGRect frame = [layoutManager usedRectForTextContainer:textContainer];
    
    return frame.size;
}

@end
