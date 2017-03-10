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
    
    if (self.audioPlayer.playing) {
        
        [self _qmPlayerStop];
    }
    else {
        
        NSError *error;
        self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url fileTypeHint:AVFileTypeMPEGLayer3 error:&error];
        
        self.status.mediaID = itemID;
        [self _qmPlayerPlay];
    }
    
    if (self.onStatusChanged) {
        self.onStatusChanged(self.status.mediaID, YES);
    }
}



//MARK: - private

- (void)_qmPlayerStop {
    
    [self stopProgressTimer];
    
    [self.audioPlayer stop];
    self.status.progress = 0.0;
    self.status.mediaID = nil;
    self.status.playerStatus = QMPlayerStatusStopped;
    self.status.currentTime = 0;
    self.audioPlayer = nil;
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
        
        CGFloat progress = self.audioPlayer.currentTime / self.audioPlayer.duration;
        self.status.progress = progress;
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
