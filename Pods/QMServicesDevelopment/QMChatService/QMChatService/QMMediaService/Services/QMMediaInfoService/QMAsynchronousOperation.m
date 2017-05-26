//
//  QMAsynchronousOperation.m
//  Pods
//
//  Created by Vitaliy Gurkovsky on 3/23/17.
//
//

#import "QMAsynchronousOperation.h"

@implementation QMAsynchronousOperation

//@synthesize ready = _ready;
@synthesize executing = _executing;
@synthesize finished = _finished;

//MARK: - Class methods

+ (instancetype)asynchronousOperationWithID:(NSString *)operationID
                                      queue:(NSOperationQueue *)queue {
    
    QMAsynchronousOperation *operation = [QMAsynchronousOperation new];
    
    if (operationID.length != 0) {
        
        operation.operationID = operationID;
        
        for (QMAsynchronousOperation *operationInQueue in queue.operations) {
            if ([operationInQueue.operationID isEqualToString:operationID]) {
                [operation addDependency:operationInQueue];
            }
        }
    }
    
    return operation;
}

+ (void)cancelOperationWithID:(NSString *)operationID
                        queue:(NSOperationQueue *)queue {
    if (operationID.length != 0) {
        
        for (QMAsynchronousOperation *operationInQueue in queue.operations) {
            if ([operationInQueue.operationID isEqualToString:operationID]) {
                [operationInQueue cancel];
                [operationInQueue complete];
            }
        }
    }
}


+ (void)cancelAllOperationsForQueue:(NSOperationQueue *)queue {
    
    for (QMAsynchronousOperation *operationInQueue in queue.operations) {
        [operationInQueue cancel];
        [operationInQueue complete];
    }
}

//MARK: - State
- (void)setExecuting:(BOOL)executing {
    if (_executing != executing) {
        [self willChangeValueForKey:NSStringFromSelector(@selector(isExecuting))];
        _executing = executing;
        [self didChangeValueForKey:NSStringFromSelector(@selector(isExecuting))];
    }
}

- (BOOL)isExecuting
{
    return _executing;
}

- (void)setFinished:(BOOL)finished
{
    if (_finished != finished)
    {
        [self willChangeValueForKey:NSStringFromSelector(@selector(isFinished))];
        _finished = finished;
        [self didChangeValueForKey:NSStringFromSelector(@selector(isFinished))];
    }
}

- (BOOL)isFinished
{
    return _finished;
}

- (BOOL)isAsynchronous
{
    return YES;
}

//MARK: - Control
- (void)cancel {
    
    [super cancel];
    
    if (self.cancellBlock) {
        self.cancellBlock();
    }
}

- (void)main {
    
    if (self.operationBlock != nil) {
        self.operationBlock();
    }
    else {
        [self complete];
    }
}

- (void)start {
    
    if (self.isCancelled) {
        self.finished = YES;
    }
    else if (!self.isExecuting && !self.isFinished) {
        
        self.executing = YES;
        [self main];
        NSLog(@"\"%@\" Operation Started.", self.operationID);
    }
}

- (void)complete {
    
    if (self.isExecuting) {
        NSLog(@"\"%@\" Operation Finished.", self.operationID);
        
        self.executing = NO;
        self.finished = YES;
    }
}

@end
