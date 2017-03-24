//
//  QMAudioRecorder.h
//  Q-municate
//
//  Created by Vitaliy Gurkovsky on 3/1/17.
//  Copyright © 2017 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

@class QMMediaItem;

typedef void(^QMAudioRecordCompletionBlock)(QMMediaItem *item, NSError *error);

typedef NS_ENUM(NSUInteger, QBRecordState) {
    QBRecordStateRecording,
    QBRecordStatePaused,
    QBRecordStateStopped
};

@interface QMAudioRecorder : NSObject

@property (copy, nonatomic) dispatch_block_t onStart;
@property (assign, nonatomic) QBRecordState recordState;


- (void)startRecording;
- (void)cancelRecording;
- (void)stopRecordingWithCompletion:(QMAudioRecordCompletionBlock)completion;

- (NSTimeInterval)duration;

@end


