//
//  QMVideoCallController.m
//  Q-municate
//
//  Created by Igor Alefirenko on 19/03/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMVideoCallController.h"
#import "QMAVCallManager.h"

@implementation QMVideoCallController

NSString *const kGoToDuringVideoCallControllerSegue= @"goToDuringVideoCallSegueIdentifier";

#pragma mark - Overridden methods

- (void)viewDidLoad {
    [super viewDidLoad];
    self.btnMic.enabled = NO;
    
    if (self.session.conferenceType == QBRTCConferenceTypeVideo) {
        [self.opponentsView layoutIfNeeded];
        [QMApi instance].avCallManager.cameraCapture.previewLayer.frame = self.opponentsView.bounds;
        [self.opponentsView.layer insertSublayer:[QMApi instance].avCallManager.cameraCapture.previewLayer atIndex:0];
    }
}

- (IBAction)stopCallTapped:(id)sender {
    [self.opponentsView setHidden:YES];
    [super stopCallTapped:sender];
}

- (void)callStartedWithUser {
    [self.contentView hide];
    [self performSegueWithIdentifier:kGoToDuringVideoCallControllerSegue sender:nil];
}

- (void)callStoppedByOpponentForReason:(NSString *)reason {
    [self.contentView show];
    [self.opponentsView setHidden:YES];
    [super callStoppedByOpponentForReason:reason];
}

#pragma mark QBRTCSession delegate -

- (void)session:(QBRTCSession *)session startedConnectingToUser:(NSNumber *)userID {
    
    if (session == self.session) {
        
        [self callStartedWithUser];
    }
}

- (void)session:(QBRTCSession *)session connectedToUser:(NSNumber *)userID {
    
  
}

- (void)session:(QBRTCSession *)session receivedRemoteVideoTrack:(QBRTCVideoTrack *)videoTrack fromUser:(NSNumber *)userID {
    
    if (session == self.session) {
        [self.opponentsView setVideoTrack:videoTrack];
    }
}

@end
