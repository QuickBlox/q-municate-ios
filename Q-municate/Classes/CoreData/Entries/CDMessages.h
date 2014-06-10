
#import "_CDMessages.h"
#import "QBDBMergeProtocol.h"

@interface CDMessages : _CDMessages <QBDBMergeProtocol>

- (QBChatHistoryMessage *)toQBChatHistoryMessage;
- (void)updateWithQBChatHistoryMessage:(QBChatHistoryMessage *)message;

@end

