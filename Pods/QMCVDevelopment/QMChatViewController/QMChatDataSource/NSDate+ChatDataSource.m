//
//  NSDate+ChatDataSource.m
//  QMChatViewController
//
//  Created by Vitaliy Gurkovsky on 8/23/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "NSDate+ChatDataSource.h"

const NSCalendarUnit componentFlags = (NSCalendarUnitYear| NSCalendarUnitMonth | NSCalendarUnitDay |  NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond);

@implementation NSDate (ChatDataSource)

- (NSCalendar *)calendar
{
    static NSCalendar *sharedCalendar = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedCalendar = [NSCalendar autoupdatingCurrentCalendar];
    });
    
    return sharedCalendar;
}

- (NSComparisonResult)compareWithDate:(NSDate *)dateToCompareWith {

    NSUInteger date1 = (NSUInteger)[self timeIntervalSince1970];
    NSUInteger date2 = (NSUInteger)[dateToCompareWith timeIntervalSince1970];
    
    if (date1 > date2) {
        return NSOrderedDescending;
    }
    else if (date2 > date1) {
        return NSOrderedAscending;
    }
    else {
        return NSOrderedSame;
    }
}

- (NSDate *)dateAtStartOfDay {
    return [[self calendar] startOfDayForDate:self];
}

- (NSDate *)dateAtEndOfDay {
    
    NSDateComponents *dateComponents = [NSDateComponents new];
    dateComponents.day = 1;
    dateComponents.second = -1;
    
 
    NSDate *endDate =  [[self calendar] dateByAddingComponents:dateComponents
                                                  toDate:[self dateAtStartOfDay]
                                                 options:0];
    return endDate;
}

- (NSString *)stringDate {
    
    return [self stringDateWithFormat:nil];
}

- (BOOL)isBetweenStartDate:(NSDate *)startDate andEndDate:(NSDate *)endDate {
    return ([self compare:startDate] == NSOrderedDescending &&
            [self compare:endDate]  == NSOrderedAscending);
}

- (NSString *)stringDateWithFormat:(NSString *)dateFormat {
    
    static NSDateFormatter *dateFormatter;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.locale = [NSLocale currentLocale];
        dateFormatter.timeZone = [self calendar].timeZone;
        [dateFormatter setDateFormat:@"d MMMM YYYY"];
    });
    
    if (dateFormat.length) {
        [dateFormatter setDateFormat:dateFormat];
    }
    
    return [dateFormatter stringFromDate:self];
}

@end
