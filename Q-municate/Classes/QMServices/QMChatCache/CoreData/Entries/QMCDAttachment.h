
#import "_QMCDAttachment.h"
#import <Quickblox/Quickblox.h>

@interface QMCDAttachment : _QMCDAttachment {}

- (QBChatAttachment *)toQBChatAttachment;
- (void)updateWithQBChatAttachment:(QBChatAttachment *)attachment;

@end
