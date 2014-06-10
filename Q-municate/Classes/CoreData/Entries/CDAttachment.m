#import "CDAttachment.h"

@implementation CDAttachment

- (QBChatAttachment *)toQBChatAttachment {
    
    QBChatAttachment *attachment = [[QBChatAttachment alloc] init];
    attachment.ID = self.uniqueId;
    attachment.url = self.url;
    attachment.type = self.type;
    
    return attachment;
    
}

- (void)updateWithQBChatAttachment:(QBChatAttachment *)attachment {
    
    self.uniqueId = attachment.ID;
    self.url = attachment.url;
    self.type = attachment.type;
}

@end
