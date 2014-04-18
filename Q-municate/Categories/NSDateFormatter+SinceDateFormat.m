//
//  NSDateFormatter+SinceDateFormat.m
//  Q-municate
//
//  Created by Igor Alefirenko on 19/02/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "NSDateFormatter+SinceDateFormat.h"

static NSString* const kSecondsKey  = @"seconds";
static NSString* const kMinutesKey  = @"minutes";
static NSString* const kHoursKey    = @"hours";
static NSString* const kDayKey      = @"day";
static NSString* const kDaysKey     = @"days";
static NSString* const kWeekKey     = @"week";
static NSString* const kWeeksKey    = @"weeks";
static NSString* const kMonthKey    = @"month";
static NSString* const kMonthsKey   = @"months";
static NSString* const kYearKey     = @"year";
static NSString* const kYearsKey    = @"years";

static const CGFloat kMinute = 60.0f;
static const CGFloat kHour = 3600.0f;
static const CGFloat kDay = 86400.0f;
static const CGFloat kWeek = 604800.0f;
static const CGFloat kMonth = 2419200.0f;
static const CGFloat kYear = 29030400.0f;

@implementation NSDateFormatter (SinceDateFormat)

- (NSDictionary *)fullTimePassedFormat
{
    
	NSDictionary *fullTimePassedFormat = @{kSecondsKey : @"%d s. ago",
                                           kMinutesKey : @"%d min. ago",
                                           kHoursKey : @"%d h. ago",
                                           kDaysKey : @"%d d. ago",
                                           kDayKey : @"%d d. ago",
                                           kWeeksKey : @"%d w. ago",
                                           kWeekKey : @"%d w. ago",
                                           kMonthsKey : @"%d m. ago",
                                           kMonthKey : @"%d m. ago",
                                           kYearsKey : @"%d y. ago",
                                           kYearKey : @"%d y. ago",};
	return fullTimePassedFormat;
}

- (NSString *)fullFormatPassedTimeFromDate:(NSDate *)date
{
	return [self timePassedToString:date withPatternDictionary:[self fullTimePassedFormat]];
}

- (NSString *)timePassedToString:(NSDate *)date withPatternDictionary:(NSDictionary *)patterns
{
	NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:date];
	
    NSString *datetimeString;
	
	if (interval < kMinute) {
		datetimeString = [NSString stringWithFormat:patterns[kSecondsKey], (int)interval];
	} else if (interval >= kMinute && interval <= kHour) {
		datetimeString = [NSString stringWithFormat:patterns[kMinutesKey], (int)(interval / kMinute)];
	} else if (interval > kHour && interval <= kDay) {
		datetimeString = [NSString stringWithFormat:patterns[kHoursKey], (int)(interval / kHour)];
	} else if (interval > kDay && interval <= kWeek) {
		datetimeString = [self formatDateTimeForDay:(int)(interval / kDay) withPatternDictionary:patterns];
	} else if (interval > kWeek && interval <= kMonth) {
        datetimeString = [self formatDateTimeForWeek:(int)(interval / kWeek) withPatternDictionary:patterns];
	} else if (interval > kMonth && interval <= kYear) {
        datetimeString = [self formatDateTimeForMonth:(int)(interval / kMonth) withPatternDictionary:patterns];
	} else if (interval > kYear) {
        datetimeString = [self formatDateTimeForYear:(int)(interval / kYear) withPatternDictionary:patterns];
	}
    
    return datetimeString;
}

///////////////////////////

- (NSString*)formatDateTimeForYear:(NSInteger)yearValue withPatternDictionary:(NSDictionary *)patterns
{
    NSString* year = nil;
    if (yearValue == 1) {
        year = [NSString stringWithFormat:patterns[kYearKey], yearValue];
    } else {
        year = [NSString stringWithFormat:patterns[kYearsKey], yearValue];
    }
    return year;
}

- (NSString*)formatDateTimeForDay:(NSInteger)dayValue withPatternDictionary:(NSDictionary *)patterns
{
    NSString* day = nil;
    if (dayValue == 1) {
        day = [NSString stringWithFormat:patterns[kDayKey], dayValue];
    } else {
        day = [NSString stringWithFormat:patterns[kDaysKey], dayValue];
    }
    return day;
}

- (NSString*)formatDateTimeForWeek:(NSInteger)weekValue withPatternDictionary:(NSDictionary *)patterns
{
    NSString* week = nil;
    if (weekValue == 1) {
        week = [NSString stringWithFormat:patterns[kWeekKey], weekValue];
    } else {
        week = [NSString stringWithFormat:patterns[kWeeksKey], weekValue];
    }
    return week;
}

- (NSString*)formatDateTimeForMonth:(NSInteger)monthValue withPatternDictionary:(NSDictionary *)patterns
{
    NSString* month = nil;
    if (monthValue == 1) {
        month = [NSString stringWithFormat:patterns[kMonthKey], monthValue];
    } else {
        month = [NSString stringWithFormat:patterns[kMonthsKey], monthValue];
    }
    return month;
}


@end
