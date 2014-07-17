 //
//  QMChatService.m
//  Q-municate
//
//  Created by Igor Alefirenko on 17/02/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMChatService.h"
#import "QMChatReceiver.h"

@interface QMChatService ()

@property (strong, nonatomic) NSTimer *presenceTimer;

@end

@implementation QMChatService

- (void)start {
    [QBChat instance].delegate = [QMChatReceiver instance];
    NSAssert(self.presenceTimer == nil, @"Need Update this case");
    self.presenceTimer = [NSTimer scheduledTimerWithTimeInterval:30
                                                          target:self
                                                        selector:@selector(sendPresence)
                                                        userInfo:nil
                                                         repeats:YES];
}

- (void)destroy {
    
    [self.presenceTimer invalidate];
    self.presenceTimer = nil;
}

- (BOOL)loginWithUser:(QBUUser *)user completion:(QBChatResultBlock)block {
    
    [self start];
    
    [[QMChatReceiver instance] chatDidLoginWithTarget:self block:block];
    [[QMChatReceiver instance] chatDidNotLoginWithTarget:self block:block];

    return [[QBChat instance] loginWithUser:user];
}

- (BOOL)logout {
    
    BOOL success = [[QBChat instance] logout];
    
    if (success) {
        [self destroy];
    }
    return success;
}

#pragma mark - STATUS

- (void)sendPresenceWithStatus:(NSString *)status {
    
    if (status) {
        [[QBChat instance] sendPresenceWithStatus:status];
    } else {
        [[QBChat instance] sendPresence];
    }
}

- (void)sendPresence {
    [[QBChat instance] sendPresence];
}

@end