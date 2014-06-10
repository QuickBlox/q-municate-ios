#import "CDMessages.h"

@interface CDMessages ()

@end

@implementation CDMessages

- (QBChatMessage *)toQBChatMessage {
    
    QBChatMessage *chatMessage = [QBChatMessage message];
    chatMessage.senderNick = self.senderNick;
    chatMessage.text = self.text;
    chatMessage.ID = self.uniqueId;
    chatMessage.recipientID = self.recipientID.intValue;
    chatMessage.senderID = self.senderId.intValue;
    
    return chatMessage;
}

- (void)updateWithQBChatMessage:(QBChatMessage *)message {
    
    self.senderNick = message.senderNick;
    self.text = message.text;
    self.uniqueId = message.ID;
    self.datetime = message.datetime;
    self.recipientID = @(message.recipientID);
    self.senderId = @(message.senderID);
}

@end
