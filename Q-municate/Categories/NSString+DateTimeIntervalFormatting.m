//
//  NSString+DateTimeIntervalFormatting.m
//  Qmunicate
//
//  Created by Igor Alefirenko on 17/07/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "NSString+DateTimeIntervalFormatting.h"

@implementation NSString (DateTimeIntervalFormatting)

- (NSString *)formattedTimeFromTimeInterval:(double_t)time {

    return [NSString stringWithFormat:@"%02u:%05.2f", (int)(time/60), fmod(time, 60)];
}

@end
