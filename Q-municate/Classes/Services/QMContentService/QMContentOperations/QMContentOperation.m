//
//  QMContentOperation.m
//  Qmunicate
//
//  Created by Andrey Ivanov on 28.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMContentOperation.h"
#import "QBEchoObject.h"

@interface QMContentOperation()

@property (strong, nonatomic) dispatch_semaphore_t sem;

@end

@implementation QMContentOperation

- (void)setProgress:(float)progress {
    
    if(self.progressHandler)
        self.progressHandler(progress);
}

- (void)completedWithResult:(Result *)result {
    
    if (self.completionHandler) {
        
        QMTaskResultBlock block = (QMTaskResultBlock)self.completionHandler;
        block(result);
    }
    
    dispatch_semaphore_signal(self.sem);
}

- (void)setCancelableOperation:(NSObject<Cancelable> *)cancelableOperation {
    
    _cancelableOperation = cancelableOperation;
    
    self.sem = dispatch_semaphore_create(0);
    dispatch_semaphore_wait(self.sem, DISPATCH_TIME_FOREVER);
}

- (void)cancel {
    
    [self.cancelableOperation cancel];
}

@end
