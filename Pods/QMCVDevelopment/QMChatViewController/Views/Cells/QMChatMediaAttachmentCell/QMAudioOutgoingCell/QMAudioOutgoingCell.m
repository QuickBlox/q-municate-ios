//
//  QMAudioOutgoingCell.m
//  Pods
//
//  Created by Vitaliy Gurkovsky on 2/13/17.
//
//

#import "QMAudioOutgoingCell.h"

@implementation QMAudioOutgoingCell

- (void)awakeFromNib {
    
    [super awakeFromNib];
    _progressView.layer.masksToBounds = YES;
    self.layer.masksToBounds = YES;
}

- (void)prepareForReuse {
    
    [super prepareForReuse];
    
    [self.progressView setProgress:0
                          animated:NO];
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    UIImage *stretchableImage = self.containerView.backgroundImage;
    
    _progressView.layer.mask = [self maskLayerFromImage:stretchableImage];
}

- (CALayer *)maskLayerFromImage:(UIImage *)image {
    
    CALayer *layer = [CALayer layer];
    
    layer.frame = self.progressView.bounds;
    layer.contents = (id)[image CGImage];
    layer.contentsScale = [image scale];
    layer.rasterizationScale = [image scale];
    CGSize imageSize = [image size];
    
    NSAssert(image.resizingMode == UIImageResizingModeStretch || UIEdgeInsetsEqualToEdgeInsets(image.capInsets, UIEdgeInsetsZero),
             @"the resizing mode of image should be stretch; if not, then its insets must be all-zero");
    
    UIEdgeInsets insets = [image capInsets];
    
    // These are lifted from what UIImageView does by experimentation. Without these exact values, the stretching is slightly off.
    const CGFloat halfPixelFudge = 0.49f;
    const CGFloat otherPixelFudge = 0.02f;
    // Convert to unit coordinates for the contentsCenter property.
    CGRect contentsCenter = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    if (insets.left > 0 || insets.right > 0) {
        contentsCenter.origin.x = ((insets.left + halfPixelFudge) / imageSize.width);
        contentsCenter.size.width = (imageSize.width - (insets.left + insets.right + 1.f) + otherPixelFudge) / imageSize.width;
    }
    if (insets.top > 0 || insets.bottom > 0) {
        contentsCenter.origin.y = ((insets.top + halfPixelFudge) / imageSize.height);
        contentsCenter.size.height = (imageSize.height - (insets.top + insets.bottom + 1.f) + otherPixelFudge) / imageSize.height;
    }
    layer.contentsGravity = kCAGravityResize;
    layer.contentsCenter = contentsCenter;
    
    return layer;
}

- (void)setCurrentTime:(NSTimeInterval)currentTime {
    [super setCurrentTime:currentTime];
    NSInteger duration = self.duration;
    NSString *timeStamp = [self timestampString:currentTime
                                    forDuration:duration];
    
    self.durationLabel.text = timeStamp;
    
    if (duration > 0) {
        BOOL animated = currentTime > 0;
        [self.progressView setProgress:currentTime/duration
                              animated:animated];
    }
}




@end
