#import "_CDLinkPreview.h"

@class QMLinkPreview;

@interface CDLinkPreview : _CDLinkPreview

- (QMLinkPreview *)toQMLinkPreview;
- (void)updateWithQMLinkPreview:(QMLinkPreview *)linkPreview;

@end
