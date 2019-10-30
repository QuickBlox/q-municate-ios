//
//  QMChatIncomingLinkPreviewCell.m
//  Pods
//
//  Created by Injoit on 3/31/17.
//  Copyright © 2017 QuickBlox. All rights reserved.
//

#import "QMChatIncomingLinkPreviewCell.h"

@implementation QMChatIncomingLinkPreviewCell

+ (QMChatCellLayoutModel)layoutModel {
    
    QMChatCellLayoutModel defaultLayoutModel = [super layoutModel];
    defaultLayoutModel.containerInsets = UIEdgeInsetsMake(8, 18, 8, 8);
    defaultLayoutModel.topLabelHeight = 0;
    defaultLayoutModel.bottomLabelHeight = 14;
    defaultLayoutModel.spaceBetweenTextViewAndBottomLabel = 0;
    defaultLayoutModel.maxWidth = 360;
    return defaultLayoutModel;
}

@end
