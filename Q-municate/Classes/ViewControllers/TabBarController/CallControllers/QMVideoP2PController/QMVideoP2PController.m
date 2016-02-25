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

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.myView layoutIfNeeded];
    [QMApi instance].avCallManager.cameraCapture.previewLayer.frame = self.myView.bounds;
    
    if (!self.disableSendingLocalVideoTrack) {
        [self.myView.layer insertSublayer:[QMApi instance].avCallManager.cameraCapture.previewLayer atIndex:0];
    } else {
        self.session.localMediaStream.videoTrack.enabled = NO;
    }
    
    [super updateButtonsState];
    
    if( [QMApi instance].avCallManager.remoteVideoTrack ){
        self.opponentVideoTrack = [QMApi instance].avCallManager.remoteVideoTrack;
    }
    
    [self.contentView startTimerIfNeeded];
    [self.opponentsView setVideoTrack:self.opponentVideoTrack];
    
    if([machineName() isEqualToString:@"iPhone3,1"] ||
       [machineName() isEqualToString:@"iPhone3,2"] ||
       [machineName() isEqualToString:@"iPhone3,3"] ||
       [machineName() isEqualToString:@"iPhone4,1"]) {
        
        self.opponentsVideoViewBottom.constant = -80.0f;
    }
}

- (void)cameraSwitchTapped:(id)sender{
	[super cameraSwitchTapped:sender];
	if( self.session.localMediaStream.videoTrack.enabled ){
		[self allowSendingLocalVideoTrack];
		[self.btnSwitchCamera setUserInteractionEnabled:YES];
	}
	else{
		[self denySendingLocalVideoTrack];
		[self.btnSwitchCamera setUserInteractionEnabled:NO];
	}
}

- (void)stopCallTapped:(id)sender {
    [self hideViewsBeforeDealloc];
    [super stopCallTapped:sender];
}

- (void)hideViewsBeforeDealloc {
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
    if( self.session.localMediaStream.videoTrack.enabled ){
        [self allowSendingLocalVideoTrack];
        [self.btnSwitchCamera setUserInteractionEnabled:YES];
    }
    else{
        [self denySendingLocalVideoTrack];
        [self.btnSwitchCamera setUserInteractionEnabled:NO];
		[super updateButtonsState];
    }
}

- (void)allowSendingLocalVideoTrack {
    // it is a view with cam_off image that we need to display when cam is off
    [self.camOffView setHidden:YES];
    [self.myView.layer insertSublayer:[QMApi instance].avCallManager.cameraCapture.previewLayer atIndex:0];
}

- (void)denySendingLocalVideoTrack {
    [[self.myView.layer.sublayers objectAtIndex:0] removeFromSuperlayer];
    // it is a view with cam_off image that we need to display when cam is off
    [self.camOffView setHidden:NO];
}

#pragma mark QBRTCSession delegate -

- (void)session:(QBRTCSession *)session disconnectedFromUser:(NSNumber *)userID {
    
    if (session == self.session) {
        [self startActivityIndicator];
    }
}

- (void)session:(QBRTCSession *)session receivedRemoteVideoTrack:(QBRTCVideoTrack *)videoTrack fromUser:(NSNumber *)userID {
    
    if (session == self.session) {
        self.opponentVideoTrack = videoTrack;
        [self.opponentsView setVideoTrack:self.opponentVideoTrack];
    }
}

- (void)session:(QBRTCSession *)session connectedToUser:(NSNumber *)userID {
    
    if (session == self.session) {
        [self stopActivityIndicator];
    }
}

- (void)session:(QBRTCSession *)session hungUpByUser:(NSNumber *)userID  userInfo:(NSDictionary *)userInfo{
    
    if (session == self.session) {
        [self hideViewsBeforeDealloc];
    }
}

@end
