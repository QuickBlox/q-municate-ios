//
//  QMAudioPlayer.m
//  Q-municate
//
//  Created by Injoit on 1/26/17.
//  Copyright © 2017 QuickBlox. All rights reserved.
//

#import "QMAudioPlayer.h"
#import "QBChatAttachment+QMCustomParameters.h"

@implementation QMAudioPlayerStatus

@end

@interface QMAudioPlayer() <AVAudioPlayerDelegate>

@property (nonatomic,strong) AVAudioPlayer *audioPlayer;
@property (strong, nonatomic) NSTimer *progressTimer;
@property (nonatomic) BOOL pausedByInterruption;

@end

@implementation QMAudioPlayer

+ (instancetype)audioPlayer {
    
    static QMAudioPlayer *audioPlayer = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        audioPlayer = [[self alloc] init];
    });
    
    return audioPlayer;
}

//MARK: - NSObject

- (instancetype)init {
    
    if (self = [super init]) {
        
        _status = [[QMAudioPlayerStatus alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(audioSessionInterruptionOccurred:)
                                                     name:AVAudioSessionInterruptionNotification
                                                   object:[AVAudioSession sharedInstance]];
    }
    
    return self;
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AVAudioSessionInterruptionNotification
                                                  object:nil];
    _audioPlayer.delegate = nil;
}

- (void)activateAttachment:(QBChatAttachment *)attachment {
    
    [self playMediaAtURL:attachment.localFileURL withID:attachment.ID];
}

- (void)playMediaAtURL:(NSURL *)url withID:(NSString *)itemID {
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
    
    QMAudioPlayerState state = self.status.playerState;
    
    if (state != QMAudioPlayerStateStopped) {
        
        if ([self.status.mediaID isEqualToString:itemID]) {
            
            if (state == QMAudioPlayerStatePaused) {
                [self _qmPlayerPlay];
            }
            else {
                [self _qmPlayerPause];
            }
            
            return;
        }
        else {
            [self _qmPlayerStop];
        }
    }
    
    NSError *error;
    
    self.status.mediaID = itemID;
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url
                                                       fileTypeHint:nil
                                                              error:&error];
    self.audioPlayer.delegate = self;
    [self _qmPlayerPlay];
}


//MARK: - private

- (void)stop {
    
    [self _qmPlayerStop];
}
- (void)pause {
    
    [self _qmPlayerPause];
}

- (void)_qmPlayerStop {
    
    if (self.status.playerState == QMAudioPlayerStateStopped) {
        return;
    }
    
    [self stopProgressTimer];
    
    [self.audioPlayer stop];
    self.status.playerState = QMAudioPlayerStateStopped;
    self.status.currentTime = 0;
    self.audioPlayer = nil;
    [self.playerDelegate player:self didUpdateStatus:self.status];
}

- (void)_qmPlayerPause {
    
    if (self.status.playerState != QMAudioPlayerStatePlaying) {
        return;
    }
    
    [self stopProgressTimer];
    
    [self.audioPlayer pause];
    self.status.playerState = QMAudioPlayerStatePaused;
    self.status.currentTime = self.audioPlayer.currentTime;
    self.status.duration = self.audioPlayer.duration;
    [self.playerDelegate player:self didUpdateStatus:self.status];
}

- (void)_qmPlayerPlay {
    
    if (self.status.playerState == QMAudioPlayerStatePlaying) {
        return;
    }
    
    [self startProgressTimer];
    
    [self.audioPlayer prepareToPlay];
    [self.audioPlayer play];
    
    self.status.playerState = QMAudioPlayerStatePlaying;
    
    self.status.duration = self.audioPlayer.duration;
    
    [self.playerDelegate player:self
                didUpdateStatus:self.status];
}


//MARK: - NSTimer

- (void)stopProgressTimer {
    
    [_progressTimer invalidate];
    _progressTimer = nil;
}


- (void)updateProgressTimer {
    
    if (self.audioPlayer.playing) {
        
        self.status.duration = self.audioPlayer.duration;
        self.status.currentTime = self.audioPlayer.currentTime;
        [self.playerDelegate player:self
                    didUpdateStatus:self.status];
    }
}


- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player
                       successfully:(BOOL)flag {
    
    if (player == self.audioPlayer && flag) {
        [self _qmPlayerStop];
    }
}

- (void)startProgressTimer {
    
    self.progressTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                          target:self
                                                        selector:@selector(updateProgressTimer)
                                                        userInfo:nil
                                                         repeats:YES];
    
    [[NSRunLoop currentRunLoop] addTimer:self.progressTimer forMode:NSRunLoopCommonModes];
}


//MARK: - AVAudioSessionInterruptionNotification

- (void)audioSessionInterruptionOccurred:(NSNotification *)notif {
    
    NSNumber *interruptionType = notif.userInfo[AVAudioSessionInterruptionTypeKey];
    
    if (!interruptionType) {
        return;
    }
    
    switch (interruptionType.unsignedIntegerValue) {
            
        case AVAudioSessionInterruptionTypeBegan: {
            
            if (self.status.playerState == QMAudioPlayerStatePlaying) {
                
                [self _qmPlayerPause];
                self.pausedByInterruption = YES;
            }
            break;
        }
        case AVAudioSessionInterruptionTypeEnded: {
            
            if (self.status.playerState == QMAudioPlayerStatePaused && _pausedByInterruption) {
                
                [self _qmPlayerPlay];
                self.pausedByInterruption = NO;
            }
            break;
        }
        default:
            break;
    }
}
- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player
                                 error:(NSError *)error {
    NSLog(@"Error %@", error);
}
@end
