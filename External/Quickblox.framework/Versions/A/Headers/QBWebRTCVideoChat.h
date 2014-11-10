//
//  QBWebRTCVideoChat.h
//  Quickblox
//
//  Created by Andrey Moskvin on 3/20/14.
//  Copyright (c) 2014 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@class QBVideoView;
@class QBXMPPMessage;

@interface QBWebRTCVideoChat : NSObject

/** Set view to which will be rendered opponent's video stream */
@property (nonatomic, retain) QBVideoView *viewToRenderOpponentVideoStream;

/** ID of video chat opponent */
@property (readonly) NSUInteger videoChatOpponentId;

/** Video chat instance custom identifier */
@property (nonatomic, retain, readonly) NSString *sessionID;

/** Video chat instance state */
@property (nonatomic, readonly) enum QBVideoChatState state;

/** Switch between speaker/headphone. Bu default - NO */
@property (nonatomic, assign) BOOL useHeadphone;

/** should be set after creating webrtc video chat and before setting viewToRenderOpponentVideoStream */
@property (assign) enum QBVideoChatConferenceType currentConferenceType;

/**
 Call user. After this your opponent will be receiving one call request per second during 15 seconds to QBChatDelegate's method 'chatDidReceiveCallRequestFromUser:conferenceType:'
 
 @param userID ID of opponent
 */
- (void)callUser:(NSUInteger)userID;

/**
 Call user. After this your opponent will be receiving one call request per second during 15 seconds to QBChatDelegate's method 'chatDidReceiveCallRequestFromUser:conferenceType:customMessage:
 
 @param userID ID of opponent
 @param customParameters Custom parameters
 */
- (void)callUser:(NSUInteger)userID customParameters:(NSDictionary *)customParameters;

/**
 Сancel call requests which is producing 'callUser:' method
 */
- (void)cancelCall;

/**
 Accept call. Opponent will receive accept signal in QBChatDelegate's method 'chatCallDidAcceptByUser:'
 
 @param userID ID of opponent
 */
- (void)acceptCallWithOpponentID:(NSUInteger)userID;

/**
 Accept call with custom parameters. Opponent will receive accept signal in QBChatDelegate's method 'chatCallDidAcceptByUser:customParameters:'
 
 @param userID ID of opponent
 @param customParameters Custom parameters
 */
- (void)acceptCallWithOpponentID:(NSUInteger)userID customParameters:(NSDictionary *)customParameters;

/**
 Reject call. Opponent will receive reject signal in QBChatDelegate's method 'chatCallDidRejectByUser:'
 
 @param userID ID of opponent
 */
- (void)rejectCallWithOpponentID:(NSUInteger)userID;

/**
 Finish call. Opponent will receive finish signal in QBChatDelegate's method 'chatCallDidStopByUser:status:' with status=kStopVideoChatCallStatus_Manually
 */
- (void)finishCall;

/**
 Finish call. Opponent will receive finish signal in QBChatDelegate's method 'chatCallDidStopByUser:status:customParameters:' with status=kStopVideoChatCallStatus_Manually
 
 @param customParameters Custom parameters
 */
- (void)finishCallWithCustomParameters:(NSDictionary *)customParameters;

@end
