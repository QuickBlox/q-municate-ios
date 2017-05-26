//
//  QMMediaIncomingCell.m
//  Pods
//
//  Created by Vitaliy Gurkovsky on 2/10/17.
//
//

#import "QMMediaIncomingCell.h"

@implementation QMMediaIncomingCell

- (void)awakeFromNib {
    
    [super awakeFromNib];
    
    self.circularProgress.tintColor = [UIColor grayColor];
    self.progressLabel.textColor = [UIColor grayColor];
    self.mediaPlayButton.tintColor = [UIColor grayColor];
    self.durationLabel.textColor = [UIColor grayColor];
}


+ (QMChatCellLayoutModel)layoutModel {
    
    QMChatCellLayoutModel defaultLayoutModel = [super layoutModel];
    defaultLayoutModel.avatarSize = CGSizeMake(0, 0);
    defaultLayoutModel.containerInsets = UIEdgeInsetsMake(4, 4, 4, 15),
    defaultLayoutModel.topLabelHeight = 0;
    defaultLayoutModel.bottomLabelHeight = 14;
    return defaultLayoutModel;
}

@end
