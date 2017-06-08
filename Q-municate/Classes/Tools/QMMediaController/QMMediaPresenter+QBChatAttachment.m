//
//  QMMediaPresenter+QBChatAttachment.m
//  Q-municate
//
//  Created by Vitaliy Gurkovsky on 3/28/17.
//  Copyright © 2017 Quickblox. All rights reserved.
//

#import "QMMediaPresenter+QBChatAttachment.h"
#import <objc/runtime.h>

@implementation QMMediaPresenter (QBChatAttachment)

- (QBChatAttachment *)attachment {
    return objc_getAssociatedObject(self, @selector(attachment));
}

- (void)setAttachment:(QBChatAttachment *)attachment {
    objc_setAssociatedObject(self, @selector(attachment), attachment, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self reloadData];
}

- (void)reloadData {
    NSTimeInterval duration = self.attachment.duration;
    [self didUpdateDuration:duration];
    
    UIImage *image = self.attachment.image;
    [self didUpdateThumbnailImage:image];
    
}


@end
