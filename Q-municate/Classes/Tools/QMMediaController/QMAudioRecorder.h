//
//  QMAudioRecorder.h
//  Q-municate
//
//  Created by Vitaliy Gurkovsky on 3/1/17.
//  Copyright © 2017 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^QMAudioRecordCompletionBlock)(NSURL *fileURL, NSTimeInterval duration, NSError *error);

typedef NS_ENUM(NSUInteger, QBRecordState) {
    QBRecordStateStopped,
    QBRecordStateRecording,
    QBRecordStatePaused
};

@interface QMAudioRecorder : NSObject

@property (nonatomic, copy) dispatch_block_t cancellBlock;
@property (nonatomic, copy) QMAudioRecordCompletionBlock completionBlock;

@property (nonatomic, assign, readonly) QBRecordState recordState;
@property (nonatomic, assign, readonly) NSTimeInterval maximumDuration;

- (void)startRecording;
- (void)startRecordingForDuration:(NSTimeInterval)duration;

- (void)cancelRecording;
- (void)stopRecording;

- (NSTimeInterval)currentTime;

@end


