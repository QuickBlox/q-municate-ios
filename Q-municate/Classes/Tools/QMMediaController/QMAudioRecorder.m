//
//  QMAudioRecorder.m
//  Q-municate
//
//  Created by Vitaliy Gurkovsky on 3/1/17.
//  Copyright © 2017 Quickblox. All rights reserved.
//

#import "QMAudioRecorder.h"
#import "QMMediaItem.h"

static const NSTimeInterval kQMMinimalDuration = 2; // in seconds

@interface QMAudioRecorder() <AVAudioRecorderDelegate>

@property (strong, nonatomic)  AVAudioRecorder *recorder;
@property (copy, nonatomic) QMAudioRecordCompletionBlock completion;

@end

@implementation QMAudioRecorder

- (instancetype)init {
    
    if (self = [super init]) {
        // Set the audio file
        NSArray *pathComponents = [NSArray arrayWithObjects:
                                   [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                                   @"tempmediaRecord.m4a",
                                   nil];
        NSURL *outputFileURL = [NSURL fileURLWithPathComponents:pathComponents];
        
        NSError *setCategoryError = NULL;
        
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryRecord error: &setCategoryError];
        if (setCategoryError){
            NSLog(@"Error setting category! %@", [setCategoryError localizedDescription]);
        }
        
        NSError *error = NULL;
        NSMutableDictionary *options = [NSMutableDictionary dictionaryWithCapacity:5];
        
        [options setValue:@(kAudioFormatMPEG4AAC) forKey:AVFormatIDKey]; //format
        [options setValue:@(44100.0) forKey:AVSampleRateKey]; //sample rate
        [options setValue:@(1) forKey:AVNumberOfChannelsKey]; //channels
        //encoder
        [options setValue:@(AVAudioQualityHigh) forKey:AVEncoderAudioQualityKey]; //channels
        [options setValue:@(16) forKey:AVEncoderBitDepthHintKey]; //channels
        
        // Initiate and prepare the recorder
        _recorder = [[AVAudioRecorder alloc] initWithURL:outputFileURL settings:options error:&error];
        _recorder.delegate = self;
        _recorder.meteringEnabled = YES;
        [_recorder prepareToRecord];
        
        
    }
    
    return self;
}

- (NSTimeInterval)duration {
    return [self.recorder currentTime];
}

- (void)dealloc {
    
    NSLog(@"QMAudioRecorderDealloc");
}

- (void)startRecording {
    [self.recorder record];
}

- (void)stopRecordingWithCompletion:(QMAudioRecordCompletionBlock)completion {
    
    [self.recorder stop];
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:NO error:nil];
    
    if (completion) {
        self.completion = [completion copy];
    }
}

- (void)cancelRecording {
    
    self.completion = nil;
    self.recorder.delegate = nil;
    [self.recorder stop];
    [self.recorder deleteRecording];
}

//MARK: -AVAudioRecorderDelegate

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    
    if (flag) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            AVURLAsset* audioAsset = [AVURLAsset URLAssetWithURL:recorder.url options:nil];
            CMTime audioDuration = audioAsset.duration;
            NSTimeInterval duration = CMTimeGetSeconds(audioDuration);
            NSData *audioData = [NSData dataWithContentsOfURL:recorder.url];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                QMMediaItem *item = nil;
                if (duration > kQMMinimalDuration) {
                    item = [QMMediaItem audioItemWithFileURL:recorder.url];
                    item.mediaDuration = duration;
                    item.data = audioData;
                }
                
                if (self.completion) {
                    self.completion(item, nil);
                }
            });
        });
    }
    else {
        if (self.completion) {
            self.completion(nil, nil);
        }
    }
}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)__unused recorder
                                   error:(NSError * __nullable)error {
    
    if (self.completion) {
        self.completion(nil, error);
    }
}


@end
