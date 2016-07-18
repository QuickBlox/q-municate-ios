//
//  QBChatMessage+QMCallNotifications.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 7/13/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QBChatMessage+QMCallNotifications.h"

static NSString * const kQMCallNotificationTypeKey = @"callType";
static NSString * const kQMCallNotificationStateKey = @"callState";

static NSString * const kQMCallNotificationCallerUserIDKey = @"caller";
static NSString * const kQMCallNotificationCalleeUserIDsKey = @"callee";

static NSString * const kQMCallNotificationCallDurationKey = @"callDuration";

@implementation QBChatMessage (QMCallNotifications)

@dynamic callNotificationType;
@dynamic callNotificationState;

#pragma mark - Methods

- (BOOL)isCallNotificationMessage {
    
    return (self.callNotificationType != QMCallNotificationTypeNone
            && self.callNotificationState != QMCallNotificationStateNone);
}

#pragma mark - Call notification type

- (QMCallNotificationType)callNotificationType {
    
    return [[self _context][kQMCallNotificationTypeKey] unsignedIntegerValue];
}

- (void)setCallNotificationType:(QMCallNotificationType)callNotificationType {
    
    [self _context][kQMCallNotificationTypeKey] = @(callNotificationType);
}

#pragma mark - Call notification state

- (QMCallNotificationState)callNotificationState {
    
    return [[self _context][kQMCallNotificationStateKey] unsignedIntegerValue];
}

- (void)setCallNotificationState:(QMCallNotificationState)callNotificationState {
    
    [self _context][kQMCallNotificationStateKey] = @(callNotificationState);
}

#pragma mark - Caller user ID

- (NSUInteger)callerUserID {
    
    return [[self _context][kQMCallNotificationCallerUserIDKey] unsignedIntegerValue];
}

- (void)setCallerUserID:(NSUInteger)callerUserID {
    
    [self _context][kQMCallNotificationCallerUserIDKey] = @(callerUserID);
}

#pragma mark - Callee user IDs

- (NSIndexSet *)calleeUserIDs {
    
    NSString *strIDs = [self _context][kQMCallNotificationCalleeUserIDsKey];
    
    NSArray *componets = [strIDs componentsSeparatedByString:@","];
    NSMutableIndexSet *indexSet = [[NSMutableIndexSet alloc] init];
    
    for (NSString *userID in componets) {
        
        [indexSet addIndex:[userID integerValue]];
    }
    
    return [indexSet copy];
}

- (void)setCalleeUserIDs:(NSIndexSet *)calleeUserIDs {
    
    NSMutableString *mutableString = [[NSMutableString alloc] init];
    
    [calleeUserIDs enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull __unused stop) {
        
        [mutableString appendFormat:@"%tu,", idx];
    }];
    
    [mutableString deleteCharactersInRange:NSMakeRange(mutableString.length - 1, 1)];
    
    [self _context][kQMCallNotificationCalleeUserIDsKey] = [mutableString copy];
}

#pragma mark - Call duration

- (NSTimeInterval)callDuration {
    
    return [[self _context][kQMCallNotificationCallDurationKey] doubleValue];
}

- (void)setCallDuration:(NSTimeInterval)callDuration {
    
    [self _context][kQMCallNotificationCallDurationKey] = @(callDuration);
}

#pragma mark - Private

- (NSMutableDictionary *)_context {
    
    if (self.customParameters == nil) {
        
        self.customParameters = [[NSMutableDictionary alloc] init];
    }
    
    return self.customParameters;
}

@end
