//
//  QMMediaOutgoingCell.m
//  Pods
//
//  Created by Injoit on 2/10/17.
//  Copyright © 2017 QuickBlox. All rights reserved.
//

#import "QMMediaOutgoingCell.h"

@implementation QMMediaOutgoingCell

+ (QMChatCellLayoutModel)layoutModel {
    
    QMChatCellLayoutModel defaultLayoutModel = [super layoutModel];
    defaultLayoutModel.avatarSize = CGSizeMake(0, 0);
    defaultLayoutModel.containerInsets = UIEdgeInsetsMake(4, 4, 4, 11);
    defaultLayoutModel.topLabelHeight = 0;
    defaultLayoutModel.bottomLabelHeight = 14;
    
    return defaultLayoutModel;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.mediaPlayButton.tintColor = [UIColor whiteColor];
    self.circularProgress.tintColor = [UIColor whiteColor];
    self.durationLabel.textColor = [UIColor whiteColor];
}

@end
