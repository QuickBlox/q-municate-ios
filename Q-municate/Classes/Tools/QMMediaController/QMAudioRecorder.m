//
//  QMAudioRecorder.m
//  Q-municate
//
//  Created by Vitaliy Gurkovsky on 3/1/17.
//  Copyright © 2017 Quickblox. All rights reserved.
//

#import "QMAudioRecorder.h"

static const NSTimeInterval kQMMinimalDuration = 1.0; // in seconds

@interface QMAudioRecorder() <AVAudioRecorderDelegate> {
    //Private variables
    NSString *_oldSessionCategory;
}

@property (strong, nonatomic)  AVAudioRecorder *recorder;
@property (copy, nonatomic) QMAudioRecordCompletionBlock completion;
@property (nonatomic) BOOL pausedByInterruption;
@property (nonatomic, assign) BOOL isCancelled;

@end

@implementation QMAudioRecorder

- (instancetype)init {
    
    if (self = [super init]) {
        
        _oldSessionCategory = [AVAudioSession sharedInstance].category;
        
        // Set the audio file
        NSArray *pathComponents =
        @[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
          [NSString stringWithFormat:@"%@.m4a",[[NSUUID new] UUIDString]]];
        
        NSURL *outputFileURL = [NSURL fileURLWithPathComponents:pathComponents];
        
        NSError *setCategoryError = NULL;
        
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord
                                               error:&setCategoryError];
        
        if (setCategoryError) {
            QMSLog(@"Error setting category! %@", [setCategoryError localizedDescription]);
            
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
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(audioSessionInterruptionOccured:)
                                                     name:AVAudioSessionInterruptionNotification
                                                   object:nil];
    }
    
    return self;
}

- (void)dealloc {
    
    _recorder.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AVAudioSessionInterruptionNotification
                                                  object:nil];
}

- (void)startRecordingForDuration:(NSTimeInterval)duration {
    
    if (duration < kQMMinimalDuration) {
        
        if (self.cancellBlock) {
            self.cancellBlock();
        }
        return;
    }
    
    _maximumDuration = duration;
    [_recorder record];
}

- (void)startRecording {
    [_recorder record];
}

- (void)pauseRecording {
    [_recorder pause];
}

- (void)stopRecording {
    [_recorder stop];
}

- (void)cancelRecording {
    
    _isCancelled = YES;
    [self stopRecording];
}

- (NSTimeInterval)currentTime {
    return [self.recorder currentTime];
}

//MARK: -AVAudioRecorderDelegate

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder
                           successfully:(BOOL)flag {
    
    [[AVAudioSession sharedInstance] setCategory:_oldSessionCategory error:nil];
    
    if (_isCancelled) {
        
        if (self.cancellBlock) {
            self.cancellBlock();
        }
        
        return;
    }
    
    if (flag) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            AVURLAsset *audioAsset = [AVURLAsset URLAssetWithURL:recorder.url options:nil];
            NSTimeInterval duration = CMTimeGetSeconds(audioAsset.duration);
            NSURL *fileURL = duration > kQMMinimalDuration ? recorder.url : nil;
            
            __weak typeof(self) weakSelf = self;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong typeof(weakSelf) strongSelf = weakSelf;
                if (strongSelf.completionBlock) {
                    strongSelf.completionBlock(fileURL, duration, nil);
                }
            });
        });
    }
    else {
        if (self.completionBlock) {
            self.completionBlock(nil, 0, nil);
        }
    }
}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)__unused recorder
                                   error:(NSError * __nullable)error {
    
    [[AVAudioSession sharedInstance] setCategory:_oldSessionCategory error:nil];
    
    if (self.completion) {
        self.completion(nil, 0, error);
    }
}

//MARK: - AVAudioSessionInterruptionNotification

- (void)audioSessionInterruptionOccured:(NSNotification *)notif {
    
    NSNumber *interruptionType = notif.userInfo[AVAudioSessionInterruptionTypeKey];
    
    if (!interruptionType) {
        return;
    }
    
    switch (interruptionType.unsignedIntegerValue) {
            
        case AVAudioSessionInterruptionTypeBegan: {
            
            if (self.recordState == QBRecordStateRecording) {
                
                self.pausedByInterruption = YES;
            }
            break;
        }
        case AVAudioSessionInterruptionTypeEnded: {
            
            if (self.recordState == QBRecordStatePaused && _pausedByInterruption) {
                
                [self.recorder record];
                self.pausedByInterruption = NO;
            }
            break;
        }
        default:
            break;
    }
}

@end
