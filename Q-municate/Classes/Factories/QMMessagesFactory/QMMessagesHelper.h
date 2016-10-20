//
//  QMMessagesHelper.h
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 4/18/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QMMessagesHelper : NSObject


/**
 *  Base chat message.
 *
 *  @param text         message text
 *  @param senderID     message sender ID
 *  @param chatDialogID chat dialog ID
 *  @param dateSent     message date sent
 *
 *  @return Base QBChatMessage instance
 */
+ (QBChatMessage *)chatMessageWithText:(nullable NSString *)text
                              senderID:(NSUInteger)senderID
                          chatDialogID:(NSString *)chatDialogID
                              dateSent:(NSDate *)dateSent;

/**
 *  Contact request notification message instance.
 *
 *  @param user       user to create notification message for
 *
 *  @return QBChatMessage notification instance
 */
+ (QBChatMessage *)contactRequestNotificationForUser:(QBUUser *)user;

/**
 *  Remove contact notification message instance.
 *
 *  @param user       user to create notification message for
 *
 *  @return QBChatMessage notification instance
 */
+ (QBChatMessage *)removeContactNotificationForUser:(QBUUser *)user;


/**
 *  Determines whether message is contact request message of any kind.
 *
 *  @param message chat message
 *
 *  @see QMMessageType
 *
 *  @return whether message is contact request message
 */
+ (BOOL)isContactRequestMessage:(QBChatMessage *)message;

@end

NS_ASSUME_NONNULL_END
