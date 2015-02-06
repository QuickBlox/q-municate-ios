//
//  QBWebRTCPeerConnectionObserver.h
//  Quickblox
//
//  Created by Andrey Moskvin on 3/20/14.
//  Copyright (c) 2014 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RTCPeerConnectionDelegate.h"


@class RTCICECandidate;
@protocol QBWebRTCPeerConnectionObserverDelegate <NSObject>

- (void)onIceCandidateReceived:(RTCICECandidate *)iceCandidate;

@end

@class QBVideoView;
@interface QBWebRTCPeerConnectionObserver : NSObject <RTCPeerConnectionDelegate>

@property (nonatomic, assign) id<QBWebRTCPeerConnectionObserverDelegate> delegate;
@property (nonatomic, strong) QBVideoView* videoView;

@end
