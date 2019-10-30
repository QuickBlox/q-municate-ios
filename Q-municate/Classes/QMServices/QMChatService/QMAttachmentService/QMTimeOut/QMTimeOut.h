//
//  QMTimeOut.h
//  Q-municate
//
//  Created by Injoit on 8/4/17.
//  Copyright © 2017 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QMTimeOut : NSObject

@property (nonatomic, assign, readonly) NSTimeInterval timeInterval;

- (instancetype)initWithTimeInterval:(NSTimeInterval)timeInterval
                               queue:(nullable dispatch_queue_t)queue;

- (void)startWithFireBlock:(dispatch_block_t)fireBlock;
- (void)cancelTimeout;

@end

NS_ASSUME_NONNULL_END
