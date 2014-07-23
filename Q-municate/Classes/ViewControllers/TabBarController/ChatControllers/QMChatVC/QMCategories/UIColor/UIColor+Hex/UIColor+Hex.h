//
//  UIColor+Hex.h
//  Qmunicate
//
//  Created by Andrey Ivanov on 18.06.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Hex)

/**
 takes @"#123456"
 */
+ (UIColor *)colorWithHex:(UInt32)col;

/**
 takes 0x123456
 */
+ (UIColor *)colorWithHexString:(NSString *)str;

@end
