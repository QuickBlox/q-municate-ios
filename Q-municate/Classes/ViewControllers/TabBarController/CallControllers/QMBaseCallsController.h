//
//  QMBaseCallsController.h
//  Qmunicate
//
//  Created by Igor Alefirenko on 01/07/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QMContentView.h"
#import "QMApi.h"
#import "QMSoundManager.h"
#import "IAButton.h"

@interface QMBaseCallsController : UIViewController<QBRTCClientDelegate>

/** Interface **/
@property (weak, nonatomic) IBOutlet IAButton *btnSpeaker;
@property (weak, nonatomic) IBOutlet IAButton *btnSwitchCamera;
@property (weak, nonatomic) IBOutlet IAButton *btnMic;
@property (weak, nonatomic) IBOutlet IAButton *btnVideo;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (weak, nonatomic) IBOutlet QMContentView *contentView;

@property (nonatomic, weak)  IBOutlet UIImageView *camOffView;

/** QBRTC **/
@property (weak, nonatomic) QBRTCSession *session;
@property (strong, nonatomic) QBRTCVideoTrack *opponentVideoTrack;
@property (nonatomic, weak)  QBRTCRemoteVideoView *opponentsView;

@property (nonatomic, strong) QBUUser *opponent;

/** Controls selectors */
- (IBAction)cameraSwitchTapped:(id)sender;
- (IBAction)muteTapped:(id)sender;
- (IBAction)videoTapped:(id)sender;
- (IBAction)speakerTapped:(id)sender;
- (IBAction)stopCallTapped:(id)sender;

- (void)callStoppedByOpponentForReason:(NSString *)reason;

- (void)startActivityIndicator;
- (void)stopActivityIndicator;

- (void)updateButtonsState;

@end
