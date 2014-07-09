 //
//  QMChatService.m
//  Q-municate
//
//  Created by Igor Alefirenko on 17/02/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMChatService.h"
#import "QMUsersService.h"
#import "QBEchoObject.h"
#import "QMChatReceiver.h"

@interface QMChatService ()

@property (strong, nonatomic) NSTimer *presenceTimer;
@property (copy, nonatomic) QBChatResultBlock chatLoginBlock;

@end

@implementation QMChatService

- (id)init {
    
    if (self = [super init]) {
        [QBChat instance].delegate = [QMChatReceiver instance];
    }
    
    return self;
}

- (BOOL)loginWithUser:(QBUUser *)user completion:(QBChatResultBlock)block {

    QBChatResultBlock result =^ (BOOL success) {
        
        self.presenceTimer = [NSTimer scheduledTimerWithTimeInterval:30
                                                              target:self
                                                            selector:@selector(sendPresence)
                                                            userInfo:nil
                                                             repeats:YES];
        block(success);
    };
    
    [[QMChatReceiver instance] chatDidLoginWithTarget:self block:result];

    return [[QBChat instance] loginWithUser:user];
}

- (BOOL)logout {
    
    BOOL success = [[QBChat instance] logout];
    if (success) {
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

#pragma mark - QMChatService
/**
 didLogin fired by QBChat when connection to service established and login is successfull
 */
- (void)chatDidLogin {
    if (self.presenceTimer == nil) {
        
    }
    self.chatLoginBlock(YES);
}

/**
 didNotLogin fired when login process did not finished successfully
 */
- (void)chatDidNotLogin {
    self.chatLoginBlock(NO);
}

@end