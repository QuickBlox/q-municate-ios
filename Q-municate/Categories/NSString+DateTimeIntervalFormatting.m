//
//  NSString+DateTimeIntervalFormatting.m
//  Qmunicate
//
//  Created by Igor Alefirenko on 17/07/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "NSString+DateTimeIntervalFormatting.h"

@implementation NSString (DateTimeIntervalFormatting)

- (NSString *)formattedTimeFromTimeInterval:(double_t)time
{
    NSString *formattedTime = nil;
    if (time <=9) {
        formattedTime = [NSString stringWithFormat:@"00:0%i",(int)time];
    } else if (time <=59) {
        formattedTime = [NSString stringWithFormat:@"00:%i", (int)time];
    } else if (time <= 359) {
        int minutes = time/60;
        int seconds = time - (minutes * 60);
        if (minutes<=9) {
            if (seconds <=9) {
                formattedTime = [NSString stringWithFormat:@"0%i:0%i", minutes, seconds];
            } else {
                formattedTime = [NSString stringWithFormat:@"0%i:%i", minutes, seconds];
            }
        } else {
            if (seconds <=9) {
                formattedTime = [NSString stringWithFormat:@"%i:0%i", minutes, seconds];
            } else {
                formattedTime = [NSString stringWithFormat:@"%i:%i", minutes, seconds];
            }
        }
    }
    return formattedTime;
}

@end
