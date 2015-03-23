//
//  QMVideoP2PController.h
//  Q-municate
//
//  Created by Anton Sokolchenko on 3/11/15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QMBaseCallsController.h"

@interface QMVideoP2PController : QMBaseCallsController

@property (weak, nonatomic) IBOutlet QBGLVideoView *opponentsView;
@property (weak, nonatomic) IBOutlet QBGLVideoView *myView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *opponentsVideoViewBottom;

/// will disable sending local video track after invoking
/// - (void)session:(QBRTCSession *)session didReceiveLocalVideoTrack
@property (assign, nonatomic) BOOL disableSendingLocalVideoTrack;
@end
