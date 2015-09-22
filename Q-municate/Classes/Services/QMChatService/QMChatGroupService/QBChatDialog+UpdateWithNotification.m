//
//  QBChatDialog+UpdateWithNotification.m
//  Q-municate
//
//  Created by Igor Alefirenko on 17.10.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QBChatDialog+UpdateWithNotification.h"

@implementation QBChatDialog (UpdateWithNotification)

- (void)updateLastMessageInfoWithMessage:(QBChatMessage *)message isMine:(BOOL)isMine
{
    self.lastMessageText = message.text;
    self.lastMessageDate = message.dateSent;
    self.lastMessageUserID = message.senderID;
    
    // if message isn't mine:
    if (!isMine) {
        self.unreadMessagesCount++;
    }
}

@end
