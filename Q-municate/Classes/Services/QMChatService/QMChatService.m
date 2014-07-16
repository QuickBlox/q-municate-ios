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

- (id)init {
    
    if (self = [super init]) {
        [QBChat instance].delegate = [QMChatReceiver instance];
    }
    
    return self;
}

- (BOOL)loginWithUser:(QBUUser *)user completion:(QBChatResultBlock)block {
    
    [[QMChatReceiver instance] chatDidLoginWithTarget:self block:^(BOOL success) {
        
        self.presenceTimer = [NSTimer scheduledTimerWithTimeInterval:30
                                                              target:self
                                                            selector:@selector(sendPresence)
                                                            userInfo:nil
                                                             repeats:YES];
        block(success);
    }];
    
    [[QMChatReceiver instance] chatDidNotLoginWithTarget:self block:block];

    return [[QBChat instance] loginWithUser:user];
}

- (BOOL)logout {
    
    BOOL success = [[QBChat instance] logout];
    
    if (success) {
        [[QMChatReceiver instance] destroy];
        [self.presenceTimer invalidate];
        self.presenceTimer = nil;
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