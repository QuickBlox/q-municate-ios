//
//  QBVideoChatSignallingService.h
//  Quickblox
//
//  Created by Andrey Moskvin on 3/25/14.
//  Copyright (c) 2014 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QBXMPPMessage.h"

@interface QBVideoChatMessageFactory : NSObject

+ (instancetype)instance;

- (QBXMPPMessage *)candidateMessageTo:(NSUInteger)opponentId
					   conferenceType:(enum QBVideoChatConferenceType)conferenceType
							sessionId:(NSString *)sessionId
					 customParameters:(NSDictionary *)customParameters;

- (QBXMPPMessage *)callRequestMessageTo:(NSUInteger)opponentId
						 conferenceType:(enum QBVideoChatConferenceType)conferenceType
							  sessionId:(NSString *)sessionId
					   customParameters:(NSDictionary *)customParameters;

- (QBXMPPMessage *)finishCallMessageTo:(NSUInteger)opponentId
						conferenceType:(enum QBVideoChatConferenceType)conferenceType
							 sessionId:(NSString *)sessionId
								status:(NSString *)status
					  customParameters:(NSDictionary *)customParameters;

- (QBXMPPMessage *)cancelCallMessageTo:(NSUInteger)opponentId
						conferenceType:(enum QBVideoChatConferenceType)conferenceType
							 sessionId:(NSString *)sessionId;

- (QBXMPPMessage *)rejectCallMessageTo:(NSUInteger)opponentId
						conferenceType:(enum QBVideoChatConferenceType)conferenceType
							 sessionId:(NSString *)sessionId;

- (QBXMPPMessage *)acceptCallMessageTo:(NSUInteger)opponentId
						conferenceType:(enum QBVideoChatConferenceType)conferenceType
							 sessionId:(NSString *)sessionId
					  customParameters:(NSDictionary *)customParameters;

- (QBXMPPMessage *)callParametersChangedMessageTo:(NSUInteger)opponentId
										sessionId:(NSString *)sessionId;

@end
