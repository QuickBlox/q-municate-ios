//
//  QMChatReceiver+Messages.m
//  Q-municate
//
//  Created by Igor Alefirenko on 26.11.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMChatReceiver.h"

@implementation QMChatReceiver (Messages)

- (void)messageHistoryWasUpdatedWithTarget:(id)target block:(void (^)(BOOL))block
{
    [self subsribeWithTarget:target selector:@selector(messageHistoryWasUpdated) block:block];
}

- (void)messageHistoryWasUpdated
{
    [self executeBloksWithSelector:_cmd enumerateBloks:^(QMChatDidLogin block) {
        block(YES);
    }];
}

@end
