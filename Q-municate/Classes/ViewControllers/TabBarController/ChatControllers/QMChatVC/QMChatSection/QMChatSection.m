//
//  QMChatSection.m
//  Q-municate
//
//  Created by Igor Alefirenko on 11/09/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMChatSection.h"
#import "QMMessage.h"

@interface QMChatSection ()

@property (strong, nonatomic) NSMutableArray *messages;
@property (assign, nonatomic) NSInteger identifier;
@property (strong, nonatomic) NSString *name;

@end


@implementation QMChatSection

- (id)initWithDate:(NSDate *)date
{
    if (self = [super init]) {
        self.messages = [[NSMutableArray alloc] init];
        self.name = [self formattedStringFromDate:date];
        self.identifier = [[self class] daysBetweenDate:date andDate:[NSDate date]];
    }
    return self;
}

- (void)addMessage:(QMMessage *)message
{
    [self.messages addObject:message];
}

+ (NSInteger)daysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime
{
    NSDate *fromDate;
    NSDate *toDate;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    [calendar rangeOfUnit:NSDayCalendarUnit startDate:&fromDate
                 interval:NULL forDate:fromDateTime];
    [calendar rangeOfUnit:NSDayCalendarUnit startDate:&toDate
                 interval:NULL forDate:toDateTime];
    
    NSDateComponents *difference = [calendar components:NSDayCalendarUnit
                                               fromDate:fromDate toDate:toDate options:0];
    
    return [difference day];
}

- (NSString *)formattedStringFromDate:(NSDate *)date
{
    NSString *formattedString = nil;
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay |
                                    NSCalendarUnitMonth |
                                    NSCalendarUnitYear fromDate:date];
    
    NSDateComponents * currentComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitDay |
                                            NSCalendarUnitMonth |
                                            NSCalendarUnitYear fromDate:[NSDate date]];
    
    if ([currentComponents isEqual:components]) {
        
        formattedString = @"Today";
        
    }
    else if (components.day == currentComponents.day - 1 &&
               components.month == currentComponents.month &&
               components.year == currentComponents.year) {
        
        formattedString = @"Yesterday";
        
    }
    else if (components.year == components.year) {
        
        formattedString = [NSString stringWithFormat:@"%@ %d", [self monthFromNumber:components.month], components.day];
    }
    else {
        
        formattedString = [NSString stringWithFormat:@"%@ %d %d", [self monthFromNumber:components.month], components.day, components.year];
    }
    return formattedString;
}

- (NSString *)monthFromNumber:(NSInteger)number {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    return dateFormatter.monthSymbols[number];
}

@end
