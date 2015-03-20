//
//  QMVideoP2PController.m
//  Q-municate
//
//  Created by Anton Sokolchenko on 3/11/15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import "QMVideoP2PController.h"
#import "QMAVCallManager.h"
#import <sys/utsname.h>



@implementation QMVideoP2PController
{
    QMAVCallManager *av;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    av = [QMApi instance].avCallManager ;
    if( av.localVideoTrack ){
        self.localVideoTrack = av.localVideoTrack;
    }
    if( av.remoteVideoTrack ){
        self.opponentVideoTrack = av.remoteVideoTrack;
    }
    
    [self.contentView startTimerIfNeeded];
    [self reloadVideoViews];
    
    if([machineName() isEqualToString:@"iPhone3,1"] || [machineName() isEqualToString:@"iPhone3,2"] || [machineName() isEqualToString:@"iPhone3,3"]||[machineName() isEqualToString:@"iPhone4,1"]){
        self.opponentsVideoViewBottom.constant = -80.0f;
    }
}

- (void)stopCallTapped:(id)sender {
    [super stopCallTapped:sender];
    [self hideViewsBeforeDealloc];
}

- (void)reloadVideoViews {
    [self.opponentsView setVideoTrack:self.opponentVideoTrack];
    [self.myView setVideoTrack:self.localVideoTrack];
}

- (void)hideViewsBeforeDealloc{
    [self.myView setVideoTrack:nil];
    [self.opponentsView setVideoTrack:nil];
    [self.myView setHidden:YES];
    [self.opponentsView setHidden:YES];
}

// to check for 4/4s screen
NSString* machineName() {
    struct utsname systemInfo;
    uname(&systemInfo);
    
    return [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
}

- (void)videoTapped:(id)sender{
    [super videoTapped:sender];
    if( [self.session videoEnabled] ){
        [self allowSendingLocalVideoTrack];
        [self.btnSwitchCamera setUserInteractionEnabled:YES];
    }
    else{
        [self denySendingLocalVideoTrack];
        [self.btnSwitchCamera setUserInteractionEnabled:NO];
    }
}

- (void)allowSendingLocalVideoTrack {
    // it is a view with cam_off image that we need to display when cam is off
    [self.camOffView setHidden:YES];
    [self reloadVideoViews];
}

- (void)denySendingLocalVideoTrack {
    [self.session setVideoEnabled:NO];
    [self.myView setVideoTrack:nil];
    // it is a view with cam_off image that we need to display when cam is off
    [self.camOffView setHidden:NO];
}

#pragma mark QBRTCSession delegate -

- (void)session:(QBRTCSession *)session disconnectedFromUser:(NSNumber *)userID {
    [super session:session disconnectTimeoutForUser:userID];
    [self startActivityIndicator];
}

- (void)session:(QBRTCSession *)session didReceiveLocalVideoTrack:(QBRTCVideoTrack *)videoTrack {
    [super session:session didReceiveLocalVideoTrack:videoTrack];
    if( self.disableSendingLocalVideoTrack ){
        [self denySendingLocalVideoTrack];
        self.disableSendingLocalVideoTrack = NO;
    }
    
    self.localVideoTrack = videoTrack;
    [self reloadVideoViews];
}

- (void)session:(QBRTCSession *)session didReceiveRemoteVideoTrack:(QBRTCVideoTrack *)videoTrack fromUser:(NSNumber *)userID {
    
    [super session:session didReceiveRemoteVideoTrack:videoTrack fromUser:userID];
    self.opponentVideoTrack = videoTrack;
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSString *category = [audioSession category];
    NSError *setCategoryError = nil;
    
    [audioSession setCategory:category
                  withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker
                        error:&setCategoryError];
    
    if (!setCategoryError) {
        av.speakerEnabled = YES;
    }
    
    [self reloadVideoViews];
}

- (void)session:(QBRTCSession *)session connectedToUser:(NSNumber *)userID {
    [super session:session connectedToUser:userID];
    [[QMSoundManager instance] stopAllSounds];
    [self stopActivityIndicator];
}

- (void)session:(QBRTCSession *)session hungUpByUser:(NSNumber *)userID{
    [self hideViewsBeforeDealloc];
    [super session:session hungUpByUser:userID];
}

@end
