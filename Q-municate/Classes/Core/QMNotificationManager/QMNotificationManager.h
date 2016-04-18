//
//  QMNotificationManager.h
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 3/26/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMBaseService.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  This class represents basic notification managing and tasks.
 */
@interface QMNotificationManager : QMBaseService

/**
 *  Contact request notification message instance.
 *
 *  @param user       user to create notification message for
 *
 *  @return QBChatMessage notification instance
 */
- (QBChatMessage *)contactRequestNotificationForUser:(QBUUser *)user;

/**
 *  Remove contact notification message instance.
 *
 *  @param user       user to create notification message for
 *
 *  @return QBChatMessage notification instance
 */
- (QBChatMessage *)removeContactNotificationForUser:(QBUUser *)user;

@end

NS_ASSUME_NONNULL_END
