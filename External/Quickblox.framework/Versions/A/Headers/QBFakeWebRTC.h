//
//  QBVideoChat.h
//  Quickblox
//
//  Created by Ivanov AV
//  Copyright (c) 2013 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#if TARGET_IPHONE_SIMULATOR

#define RTCVideoTrack QBRTCFakeClass
#define RTCVideoRenderer QBRTCFakeClass
#define RTCEAGLVideoView QBRTCFakeClass
#define RTCVideoRendererDelegate QBRTCFakeDelegate
#define RTCI420Frame QBRTCFakeClass
#define RTCSessionDescriptionDelegate QBRTCFakeDelegate
#define RTCPeerConnection QBRTCFakeClass
#define RTCPeerConnectionFactory QBRTCFakeClass
#define RTCSessionDescription QBRTCFakeClass
#define RTCVideoCapturer QBRTCFakeClass
#define RTCMediaStream QBRTCFakeClass
#define RTCAudioTrack QBRTCFakeClass
#define RTCVideoSource QBRTCFakeClass
#define RTCICEServer QBRTCFakeClass
#define RTCMediaConstraints QBRTCFakeClass
#define RTCPair QBRTCFakeClass
#define RTCICECandidate QBRTCFakeClass
//************************************************************************************************

@protocol QBRTCFakeDelegate<NSObject>
@optional
- (void)mediaStreamTrackDidChange:(id)mediaStreamTrack;
- (void)renderer:(id)renderer didSetSize:(CGSize)size;
- (void)renderer:(id)renderer didReceiveFrame:(id)frame;

@end

// Interface for rendering VideoFrames from a VideoTrack
@interface QBRTCFakeClass : NSObject

@property(nonatomic, weak) id<QBRTCFakeDelegate> delegate;
@property(nonatomic, strong, readonly) NSArray *renderers;
@property(nonatomic, readonly) NSString* kind;
@property(nonatomic, readonly) NSString* label;
@property(assign, nonatomic) int autoresizingMask;
@property(nonatomic, strong) id videoTrack;
@property(nonatomic, copy, readonly) NSString *description;
@property(nonatomic, copy, readonly) NSString *type;
@property(nonatomic, copy, readonly) NSString* sdpMid;
@property(nonatomic, assign, readonly) NSInteger sdpMLineIndex;
@property(nonatomic, copy, readonly) NSString* sdp;
@property(nonatomic) CGAffineTransform transform;

- (id)init __attribute__((
                          unavailable("init is not a supported initializer for this class.")));
- (instancetype)initWithDelegate:(id<QBRTCFakeDelegate>)delegate;
- (instancetype)initWithView:(UIView*)view;
- (void)removeFromSuperview;
- (void)addRenderer:(id)renderer;
- (void)removeRenderer:(id)renderer;
- (BOOL)isEnabled;
- (BOOL)setEnabled:(BOOL)enabled;
- (int)state;
- (BOOL)setState:(int)state;
- (id)initWithType:(NSString *)type sdp:(NSString *)sdp;
- (id)initWithMid:(NSString*)sdpMid
            index:(NSInteger)sdpMLineIndex
              sdp:(NSString*)sdp;
- (id)initWithFrame:(CGRect)frame;

+ (void)initializeSSL;
+ (void)deinitializeSSL;

- (id)peerConnectionWithICEServers:(NSArray *)servers constraints:(id)constraints delegate:(id)delegate;

- (id)mediaStreamWithLabel:(NSString *)label;

- (id)videoSourceWithCapturer:(id)capturer
                  constraints:(id)constraints;

- (id)videoTrackWithID:(NSString *)videoId
                source:(id)source;

- (id)audioTrackWithID:(NSString *)audioId;

+ (id)capturerWithDeviceName:(NSString *)deviceName;

@property(nonatomic, strong, readonly) NSArray *audioTracks;
@property(nonatomic, strong, readonly) NSArray *videoTracks;

- (BOOL)addAudioTrack:(id)track;
- (BOOL)addVideoTrack:(id)track;
- (BOOL)removeAudioTrack:(id)track;
- (BOOL)removeVideoTrack:(id)track;


@property(nonatomic, strong, readonly) NSURL* URI;
@property(nonatomic, copy, readonly) NSString* username;
@property(nonatomic, copy, readonly) NSString* password;

// Initializer for RTCICEServer taking uri, username, and password.
- (id)initWithURI:(NSURL*)URI
         username:(NSString*)username
         password:(NSString*)password;

- (id)initWithMandatoryConstraints:(NSArray *)mandatory
               optionalConstraints:(NSArray *)optional;

- (id)initWithKey:(NSString *)key value:(NSString *)value;

@property(nonatomic, strong, readonly) NSArray *localStreams;
@property(nonatomic, assign, readonly) int localDescription;
@property(nonatomic, assign, readonly) int remoteDescription;
@property(nonatomic, assign, readonly) int signalingState;
@property(nonatomic, assign, readonly) int iceConnectionState;
@property(nonatomic, assign, readonly) int iceGatheringState;

- (BOOL)addStream:(id)stream
      constraints:(id)constraints;

- (void)removeStream:(id)stream;

// Create a data channel.
- (id)createDataChannelWithLabel:(NSString*)label
                          config:(id)config;
- (void)createOfferWithDelegate:(id)delegate
                    constraints:(id)constraints;
- (void)createAnswerWithDelegate:(id)delegate
                     constraints:(id)constraints;
- (void) setLocalDescriptionWithDelegate:(id)delegate sessionDescription:(id)sdp;
- (void) setRemoteDescriptionWithDelegate:(id)delegate sessionDescription:(id)sdp;
- (BOOL)updateICEServers:(NSArray *)servers constraints:(id)constraints;
- (BOOL)addICECandidate:(id)candidate;
- (void)close;
- (BOOL)getStatsWithDelegate:(id)delegate
            mediaStreamTrack:(id)mediaStreamTrack
            statsOutputLevel:(id)statsOutputLevel;

@end

#else

#import "RTCVideoRenderer.h"
#import "RTCVideoTrack.h"
#import "RTCEAGLVideoView.h"

#import "RTCPeerConnection.h"
#import "RTCPeerConnectionFactory.h"
#import "RTCMediaConstraints.h"
#import "RTCPair.h"
#import <RTCICEServer.h>
#import "RTCMediaStream.h"
#import "RTCVideoCapturer.h"
#import "RTCSessionDescription.h"
#import "RTCICECandidate.h"
#import "RTCSessionDescriptionDelegate.h"

#endif

