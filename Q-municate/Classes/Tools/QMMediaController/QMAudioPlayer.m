//
//  QMAudioPlayer.m
//  Q-municate
//
//  Created by Vitaliy Gurkovsky on 1/26/17.
//  Copyright © 2017 Quickblox. All rights reserved.
//

#import "QMAudioPlayer.h"
#import "QMMediaItem.h"

@implementation QMAudioPlayerStatus

@end


@interface QMAudioPlayer() <AVAudioPlayerDelegate>

@property (nonatomic,strong) AVAudioPlayer *audioPlayer;
@property (strong, nonatomic) NSTimer *progressTimer;

@end

@implementation QMAudioPlayer

+ (instancetype)audioPlayer {
    static QMAudioPlayer *audioPlayer = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        audioPlayer = [[QMAudioPlayer alloc] init];
    });
    return audioPlayer;
}

- (instancetype)init {
    
    if (self = [super init]) {
        _status = [[QMAudioPlayerStatus alloc] init];
        
    }
    return self;
    
}

- (void)activateMedia:(QMMediaItem *)item {
    [self activateMediaAtURL:item.localURL withID:item.mediaID];
}

- (void)activateMediaAtURL:(NSURL *)url withID:(NSString *)itemID {
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
    
    QMPlayerStatus status = self.status.playerStatus;
    
    if (status != QMPlayerStatusStopped) {
        
        if ([self.status.mediaID isEqualToString:itemID]) {
            
            if (status == QMPlayerStatusPaused) {
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
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url fileTypeHint:AVFileTypeMPEGLayer3 error:&error];
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
    
    [self stopProgressTimer];
    
    [self.audioPlayer stop];
    self.status.progress = 0.0;
    self.status.playerStatus = QMPlayerStatusStopped;
    self.status.currentTime = 0;
    self.audioPlayer = nil;
    [self.playerDelegate player:self didChangePlayingStatus:self.status];
}

- (void)_qmPlayerPause {
    
    [self stopProgressTimer];
    
    [self.audioPlayer pause];
    self.status.playerStatus = QMPlayerStatusPaused;
    self.status.currentTime = self.audioPlayer.currentTime;
    self.status.duration = self.audioPlayer.duration;
    [self.playerDelegate player:self didChangePlayingStatus:self.status];
}

- (void)_qmPlayerPlay {
    [self startProgressTimer];
    
    [self.audioPlayer prepareToPlay];
    [self.audioPlayer play];
    self.status.progress = 0.0;
    self.status.playerStatus = QMPlayerStatusPlaying;
    
    self.status.duration = self.audioPlayer.duration;
    
    [self.playerDelegate player:self didChangePlayingStatus:self.status];
}

//MARK: - Timer
- (void)stopProgressTimer {
    
    [_progressTimer invalidate];
    _progressTimer = nil;
}


- (void)updateProgressTimer {
    
    if (self.audioPlayer.playing) {
        
        self.status.duration = self.audioPlayer.duration;
        self.status.currentTime = self.audioPlayer.currentTime;
        [self.playerDelegate player:self didChangePlayingStatus:self.status];
    }
}


- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    
    if (player == self.audioPlayer && flag) {
        [self _qmPlayerStop];
    }
}

- (void)startProgressTimer {
    self.progressTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateProgressTimer) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.progressTimer forMode:NSRunLoopCommonModes];
}

@end
