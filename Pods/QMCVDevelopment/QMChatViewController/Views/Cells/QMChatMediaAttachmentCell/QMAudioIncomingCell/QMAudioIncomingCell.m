//
//  QMAudioIncomingCell.m
//  Pods
//
//  Created by Vitaliy Gurkovsky on 2/13/17.
//
//

#import "QMAudioIncomingCell.h"

@implementation QMAudioIncomingCell

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
