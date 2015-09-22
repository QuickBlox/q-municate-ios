//
//  QMChatReceiver+DialogsHistoryUpdated.m
//  Q-municate
//
//  Created by Andrey Ivanov on 11.08.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMChatReceiver.h"

@implementation QMChatReceiver (DialogsHistoryUpdated)

- (void)postDialogsHistoryUpdated {
    
    [self executeBloksWithSelector:_cmd enumerateBloks:^(QMDialogsHistoryUpdated block) {
        block();
    }];
    
}

- (void)dialogsHisotryUpdatedWithTarget:(id)target block:(QMDialogsHistoryUpdated)block {
    [self subsribeWithTarget:target selector:@selector(postDialogsHistoryUpdated) block:block];
}

@end
