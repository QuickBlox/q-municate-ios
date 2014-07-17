//
//  QMChatService.h
//  Q-municate
//
//  Created by Igor Alefirenko on 17/02/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QMServiceProtocol.h"

@interface QMChatService : NSObject <QMServiceProtocol>

/**
 Authorize on QuickBlox Chat
 
 @param user QBUUser structure represents user's login. Required user's fields: ID, password;
 @return YES if the request was sent successfully. If not - see log.
 */
- (BOOL)loginWithUser:(QBUUser *)user completion:(QBChatResultBlock)block;

/**
 Logout current user from Chat
 
 @return YES if the request was sent successfully. If not - see log.
 */
- (BOOL)logout;

@end
