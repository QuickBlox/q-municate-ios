//
//  NSString+QM.m
//  QMChatViewController
//
//  Created by Injoit on 21.04.15.
//  Copyright © 2015 QuickBlox. All rights reserved.
//

#import "NSString+QM.h"

@implementation NSString (QM)

- (NSString *)stringByTrimingWhitespace {
    
    NSString *squashed =
    [self stringByReplacingOccurrencesOfString:@"[ ]+"
                                    withString:@" "
                                       options:NSRegularExpressionSearch range:NSMakeRange(0, self.length)];
    
    return [squashed stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

@end
