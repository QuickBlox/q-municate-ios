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

@property (weak, nonatomic) IBOutlet QBRTCRemoteVideoView *opponentsView;
@property (weak, nonatomic) IBOutlet UIView *myView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *opponentsVideoViewBottom;

@property (assign, nonatomic) BOOL disableSendingLocalVideoTrack;

@end
