//
//  QMChatOutgoingLinkPreviewCell.m
//  Pods
//
//  Created by Injoit on 3/31/17.
//  Copyright © 2017 QuickBlox. All rights reserved.
//

#import "QMChatOutgoingLinkPreviewCell.h"


@implementation QMChatOutgoingLinkPreviewCell

+ (QMChatCellLayoutModel)layoutModel {
    
    QMChatCellLayoutModel defaultLayoutModel = [super layoutModel];
    defaultLayoutModel.avatarSize = CGSizeMake(0, 0);
    defaultLayoutModel.containerInsets = UIEdgeInsetsMake(8, 10, 8, 18);
    defaultLayoutModel.spaceBetweenTextViewAndBottomLabel = 0;
    defaultLayoutModel.topLabelHeight = 0;
    defaultLayoutModel.bottomLabelHeight = 14;
    defaultLayoutModel.maxWidth = 330;
    
    return defaultLayoutModel;
}

@end
