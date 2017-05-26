//
//  QMAsynchronousOperation.h
//  Pods
//
//  Created by Vitaliy Gurkovsky on 3/23/17.
//
//

#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN

typedef  void(^QMOperationBlock)();
typedef  void(^QMCancellBlock)();

@interface QMAsynchronousOperation : NSOperation

@property (nonatomic, copy, nullable) NSString *operationID;
@property (nonatomic, copy, nullable) QMOperationBlock operationBlock;
@property (nonatomic, copy, nullable) QMCancellBlock cancellBlock;

- (void)complete;
- (void)cancel;

+ (instancetype)asynchronousOperationWithID:(NSString *)operationID
                                      queue:(NSOperationQueue *)queue;

+ (void)cancelOperationWithID:(NSString *)operationID
                        queue:(NSOperationQueue *)queue;

+ (void)cancelAllOperationsForQueue:(NSOperationQueue *)queue;

@end
NS_ASSUME_NONNULL_END
