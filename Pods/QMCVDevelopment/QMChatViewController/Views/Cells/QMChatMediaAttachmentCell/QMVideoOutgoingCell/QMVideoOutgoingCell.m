//
//  QMVideoOutgoingCell.m
//  Pods
//
//  Created by Vitaliy Gurkovsky on 2/13/17.
//
//

#import "QMVideoOutgoingCell.h"

@implementation QMVideoOutgoingCell


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
