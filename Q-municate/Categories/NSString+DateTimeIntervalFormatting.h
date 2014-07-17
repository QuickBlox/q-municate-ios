//
//  NSString+DateTimeIntervalFormatting.h
//  Qmunicate
//
//  Created by Igor Alefirenko on 17/07/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (DateTimeIntervalFormatting)

- (NSString *)formattedTimeFromTimeInterval:(double_t)time;

@end
