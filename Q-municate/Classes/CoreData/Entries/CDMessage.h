#import "_CDMessage.h"

@interface CDMessage : _CDMessage {}
- (QBChatMessage *)toQBChatHistoryMessage;
- (void)updateWithQBChatHistoryMessage:(QBChatMessage *)message;
@end
