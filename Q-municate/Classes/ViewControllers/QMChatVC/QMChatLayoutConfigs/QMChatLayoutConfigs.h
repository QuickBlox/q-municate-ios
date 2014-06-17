//
//  QMChatLayoutConfigs.h
//  Q-municate
//
//  Created by Andrey on 13.06.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

extern const struct QMChatCellLayoutConfig {
    
    CGFloat messageTopMargin;
    CGFloat messageBottomMargin;
    
    CGFloat messageLeftMargin;
    CGFloat messageRightMargin;
    
    CGFloat messageMaxWidth;
    
    CGFloat balloonMinWidth;
    CGFloat balloonMinHeight;
    
    CGFloat balloonTopMargin;
    CGFloat balloonBottomMargin;
    
    CGSize userImageSize;
    CGSize textSize;
    
    CGFloat fontSize;
    
    __unsafe_unretained  NSString *fontName;
    __unsafe_unretained  NSString *babbleImageName;
}

QMChatCellLayoutConfigRect,
QMChatCellLayoutConfigBubble;

typedef struct QMChatCellLayoutConfig QMChatCellLayoutConfig;

