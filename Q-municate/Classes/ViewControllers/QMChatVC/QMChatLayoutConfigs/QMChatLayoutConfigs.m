//
//  QMChatLayoutConfigs.m
//  Q-municate
//
//  Created by Andrey on 13.06.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMChatLayoutConfigs.h"

const struct QMChatCellLayoutConfig QMChatCellLayoutConfigBubble = {
    
    .messageTopMargin = 5,
    .messageBottomMargin = 5,
    .messageLeftMargin = 5,
    .messageRightMargin = 10,
    .messageMaxWidth = 200,
    .balloonMinWidth = 34,
    .balloonMinHeight = 34,
    .balloonTopMargin = 20,
    .balloonBottomMargin = 5,
    .userImageSize = (CGSize){.width = 40, .height = 40},
    .fontName = @"HelveticaNeue-Light",
    .fontSize = 16,
    .babbleImageName = @"bubbleReceive"
    
};

const struct QMChatCellLayoutConfig QMChatCellLayoutConfigRect = {
    
    .messageTopMargin = 2,
    .messageBottomMargin = 2,
    .messageLeftMargin = 5,
    .messageRightMargin = 5,
    .messageMaxWidth = 0,
    .balloonMinWidth = 0,
    .balloonMinHeight = 0,
    .balloonTopMargin = 15,
    .balloonBottomMargin = 15,
    .userImageSize = (CGSize){.width = 30, .height = 30},
    .fontName = @"HelveticaNeue-Light",
    .fontSize = 16,
    .babbleImageName = @"bubbleReceive"
    
};