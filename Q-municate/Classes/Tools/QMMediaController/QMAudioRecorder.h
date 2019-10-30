//
//  QMAudioRecorder.h
//  Q-municate
//
//  Created by Injoit on 3/1/17.
//  Copyright © 2017 QuickBlox. All rights reserved.
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
- (void)pauseRecording;
- (void)cancelRecording;
- (void)stopRecording;

- (NSTimeInterval)currentTime;

@end


