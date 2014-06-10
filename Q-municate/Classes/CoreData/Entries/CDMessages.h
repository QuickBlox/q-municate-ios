#import "_CDMessages.h"

@interface CDMessages : _CDMessages {}

- (QBChatMessage *)toQBChatMessage;
- (void)updateWithQBChatMessage:(QBChatMessage *)message;

@end
