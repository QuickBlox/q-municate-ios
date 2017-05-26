//
//  QMVideoIncomingCell.m
//  Pods
//
//  Created by Vitaliy Gurkovsky on 2/13/17.
//
//

#import "QMVideoIncomingCell.h"

@implementation QMVideoIncomingCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.previewImageView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
}
- (void)setDuration:(NSTimeInterval)duration {
    
    if (duration > 0) {
        self.durationLabel.text = [self timestampStringForDuration:duration];
    }
}

- (NSString *)timestampStringForDuration:(NSTimeInterval)duration {
    
    if (duration < 60) {
        return [NSString stringWithFormat:@"0:%02d", (int)round(duration)];
    }
    else if (duration < 3600) {
        return [NSString stringWithFormat:@"%d:%02d", (int)duration / 60, (int)duration % 60];
    }
    
    return [NSString stringWithFormat:@"%d:%02d:%02d", (int)duration / 3600, (int)duration / 60, (int)duration % 60];
}

@end
