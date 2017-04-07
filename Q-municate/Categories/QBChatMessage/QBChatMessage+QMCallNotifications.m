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

//MARK: - Methods

- (BOOL)isCallNotificationMessage {
    
    return (self.callNotificationType != QMCallNotificationTypeNone
            && self.callNotificationState != QMCallNotificationStateNone);
}

//MARK: - Call notification type

- (QMCallNotificationType)callNotificationType {
    
    return [[self _context][kQMCallNotificationTypeKey] integerValue];
}

- (void)setCallNotificationType:(QMCallNotificationType)callNotificationType {
    
    [self _context][kQMCallNotificationTypeKey] = @(callNotificationType);
}

//MARK: - Call notification state

- (QMCallNotificationState)callNotificationState {
    
    return [[self _context][kQMCallNotificationStateKey] integerValue];
}

- (void)setCallNotificationState:(QMCallNotificationState)callNotificationState {
    
    [self _context][kQMCallNotificationStateKey] = @(callNotificationState);
}

//MARK: - Caller user ID

- (NSUInteger)callerUserID {
    
    return [[self _context][kQMCallNotificationCallerUserIDKey] integerValue];
}

- (void)setCallerUserID:(NSUInteger)callerUserID {
    
    [self _context][kQMCallNotificationCallerUserIDKey] = @(callerUserID);
}

//MARK: - Callee user IDs

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

//MARK: - Call duration

- (NSTimeInterval)callDuration {
    
    return [[self _context][kQMCallNotificationCallDurationKey] doubleValue];
}

- (void)setCallDuration:(NSTimeInterval)callDuration {
    
    [self _context][kQMCallNotificationCallDurationKey] = @(callDuration);
}

//MARK: - Private

- (NSMutableDictionary *)_context {
    
    if (self.customParameters == nil) {
        
        self.customParameters = [[NSMutableDictionary alloc] init];
    }
    
    return self.customParameters;
}

@end
