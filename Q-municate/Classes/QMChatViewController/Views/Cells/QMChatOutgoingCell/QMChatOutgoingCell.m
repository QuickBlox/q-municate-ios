//
//  QMChatOutgoingCell.m
//  QMChatViewController
//
//  Created by Injoit on 29.05.15.
//  Copyright © 2015 QuickBlox. All rights reserved.
//

#import "QMChatOutgoingCell.h"

@implementation QMChatOutgoingCell

+ (QMChatCellLayoutModel)layoutModel {
    
    QMChatCellLayoutModel defaultLayoutModel = [super layoutModel];
    defaultLayoutModel.avatarSize = CGSizeMake(0, 0);
    defaultLayoutModel.containerInsets = UIEdgeInsetsMake(8, 10, 8, 18);
    defaultLayoutModel.topLabelHeight = 0;
    defaultLayoutModel.spaceBetweenTextViewAndBottomLabel = 0;
    defaultLayoutModel.bottomLabelHeight = 14;
    
    return defaultLayoutModel;
}

@end
