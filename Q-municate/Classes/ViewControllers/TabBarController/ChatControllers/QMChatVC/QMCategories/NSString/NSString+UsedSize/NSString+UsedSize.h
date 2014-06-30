//
//  NSString+UsedSize.h
//  Q-municate
//
//  Created by Andrey on 13.06.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (UsedSize)

- (CGSize)usedSizeForMaxWidth:(CGFloat)width font:(UIFont *)font withAttributes:(NSDictionary *)attributes;

@end
