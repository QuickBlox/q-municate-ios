#import "_CDMessage.h"

@interface CDMessage : _CDMessage {}
- (QBChatHistoryMessage *)toQBChatHistoryMessage;
- (void)updateWithQBChatHistoryMessage:(QBChatHistoryMessage *)message;
@end
