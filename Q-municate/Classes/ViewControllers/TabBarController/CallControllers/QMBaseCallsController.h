//
//  QMBaseCallsController.h
//  Qmunicate
//
//  Created by Igor Alefirenko on 01/07/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QMContentView.h"
#import "QMChatService.h"
#import "QMSoundManager.h"
#import "QMincomingCallService.h"



@interface QMBaseCallsController : UIViewController

@property (nonatomic, assign) BOOL isOpponentCaller;

/** Controls */
@property (nonatomic, weak) IBOutlet UIButton *leftControlButton;
@property (nonatomic, weak) IBOutlet UIButton *rightControlButton;
@property (nonatomic, weak) IBOutlet UIButton *stopCallButton;

/** Content View */
@property (weak, nonatomic) IBOutlet QMContentView *contentView;
@property (nonatomic, weak)  QBVideoView *opponentsView;

@property (nonatomic, strong) QBUUser *opponent;

/** Controls selectors */
- (IBAction)leftControlTapped:(id)sender;
- (IBAction)rightControlTapped:(id)sender;
- (IBAction)stopCallTapped:(id)sender;

/** Override actions in child */
- (void)startCall;
- (void)confirmCall;

/** Override callbacks in child if needed */
- (void)callAcceptedByUser;
- (void)callStartedWithUser;
- (void)callRejectedByUser;
- (void)callStoppedByOpponentForReason:(NSNotification *)notification;

@end
