//
//  QMChatNotificationCell.m
//  QMChatViewController
//
//  Created by Andrey Ivanov on 03.06.15.
//  Copyright (c) 2015 QuickBlox Team. All rights reserved.
//

#import "QMChatNotificationCell.h"

@implementation QMChatNotificationCell

+ (QMChatCellLayoutModel)layoutModel {
    
    QMChatCellLayoutModel defaultLayoutModel = [super layoutModel];
    
    defaultLayoutModel.containerInsets = UIEdgeInsetsMake(4, 10, 4, 10);
    defaultLayoutModel.avatarSize = CGSizeMake(0, 0);
    defaultLayoutModel.topLabelHeight = 0;
    defaultLayoutModel.bottomLabelHeight = 0;
    
    return defaultLayoutModel;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.notificationLabel.backgroundColor = [UIColor clearColor];
}

@end
