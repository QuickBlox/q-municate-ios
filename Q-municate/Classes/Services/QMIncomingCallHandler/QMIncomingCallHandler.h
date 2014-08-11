//
//  QMIncomingCallHandler.h
//  Q-municate
//
//  Created by Igor Alefirenko on 19/02/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QMIncomingCallController.h"

@interface QMIncomingCallHandler : NSObject

@property (strong, nonatomic) NSDateFormatter *dateFormatter;

- (void)showIncomingCallControllerWithOpponentID:(NSUInteger)opponentID conferenceType:(enum QBVideoChatConferenceType)conferenceType;
- (void)hideIncomingCallControllerWithStatus:(NSString *)status;

@end
