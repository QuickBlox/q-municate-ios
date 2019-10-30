//
//  QMAudioIncomingCell.m
//  Pods
//
//  Created by Injoit on 2/13/17.
//  Copyright © 2017 QuickBlox. All rights reserved.
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
    
    _progressView.layer.mask = [self maskLayerFromImage:stretchableImage
                                              withFrame:_progressView.bounds];
}

- (void)setCurrentTime:(NSTimeInterval)currentTime {

    [super setCurrentTime:currentTime];
    
    NSInteger duration = self.duration;
    
    NSString *timeStamp = [self timestampString:currentTime
                                    forDuration:duration];
    
    self.durationLabel.text = timeStamp;
    
    if (duration > 0) {
        BOOL animated = self.viewState == QMMediaViewStateActive && currentTime > 0;
        [self.progressView setProgress:currentTime/duration
                              animated:animated];
    }
}

+ (QMChatCellLayoutModel)layoutModel {
    
    QMChatCellLayoutModel defaultLayoutModel = [super layoutModel];
    defaultLayoutModel.avatarSize = CGSizeMake(0, 0);
    defaultLayoutModel.containerInsets = UIEdgeInsetsMake(0, 8, 0, 0);
    defaultLayoutModel.staticContainerSize = CGSizeMake(182, 48);
    
    return defaultLayoutModel;
}

@end
