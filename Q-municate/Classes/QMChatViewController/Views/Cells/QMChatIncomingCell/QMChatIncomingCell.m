//
//  QMChatIncomingCell.m
//  QMChatViewController
//
//  Created by Injoit on 29.05.15.
//  Copyright © 2015 QuickBlox. All rights reserved.
//

#import "QMChatIncomingCell.h"

@implementation QMChatIncomingCell

- (void)awakeFromNib {
    
    [super awakeFromNib];
}

+ (QMChatCellLayoutModel)layoutModel {
    
    QMChatCellLayoutModel defaultLayoutModel = [super layoutModel];
    defaultLayoutModel.containerInsets = UIEdgeInsetsMake(8, 18, 8, 10);
    
    return defaultLayoutModel;
}

@end
