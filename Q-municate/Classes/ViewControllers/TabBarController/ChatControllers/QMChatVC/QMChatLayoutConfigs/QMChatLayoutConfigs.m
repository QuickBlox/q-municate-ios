//
//  QMChatLayoutConfigs.m
//  Q-municate
//
//  Created by Andrey on 13.06.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMChatLayoutConfigs.h"

const CGFloat kQMMessageMaxWidth = 200;
const CGFloat kQMMessageMinWidth = 15;

struct QMChatBalloon QMChatBalloonNull = {
    
    .imageName = @"",
    .hexTintColor = @"",
    .imageCapInsets= (UIEdgeInsets){0, 0, 0, 0},
};

struct QMMessageLayout QMMessageQmunicateLayout = {
    
    .messageMargin = {
        .top = 5,
        .left = 5,
        .bottom = 5,
        .right = 5,
    },
    
    .messageMaxWidth = kQMMessageMaxWidth,
    
    .userImageSize = (CGSize){36,36},
    
    .fontName = @"HelveticaNeue",
    .fontSize = 12,

    .leftBalloon = {
        .imageName = @"qm_balloon_left",
        .imageCapInsets= (UIEdgeInsets){7, 13, 8, 7},
        .hexTintColor = @"#e2ebf2",
        .textColor = @"#FFFFFF"
    },
    
    .rightBalloon = {
        .imageName = @"qm_balloon_right",
        .imageCapInsets = (UIEdgeInsets){7, 7, 8, 13},
        .hexTintColor = @"#17d14b",
        .textColor = @"#000"
    },
};

struct QMMessageLayout QMMessageBubbleLayout = {
    
    .messageMargin = {
        .top = 10,
        .left = 10,
        .bottom = 10,
        .right = 10,
    },
    
    .messageMaxWidth = kQMMessageMaxWidth,
    .messageMinWidth = kQMMessageMinWidth,
    
    .userImageSize = (CGSize){40,40},
    
    .fontName = @"HelveticaNeue-UltraLight",
    .fontSize = 14,
    
    .leftBalloon = {
        .imageName = @"qm_balloon_left",
        .hexTintColor = @"#17d14b",
        .imageCapInsets = (UIEdgeInsets){7, 13, 8, 7},
    },
    
    .rightBalloon = {
        .imageName = @"qm_balloon_right",
        .imageCapInsets = (UIEdgeInsets){7, 7, 8, 13},
        .hexTintColor = @"#e2ebf2",
    },
};

struct QMMessageLayout QMMessageAttachmentLayout = {
    
    .messageMargin = {
        .top = 5,
        .left = 5,
        .bottom = 5,
        .right = 5,
    },
    
    .messageMaxWidth = kQMMessageMaxWidth,
    .messageMinWidth = kQMMessageMinWidth,

    .userImageSize = (CGSize){36,36},
    
    .fontName = @"HelveticaNeue-Light",
    .fontSize = 16,
    
    .leftBalloon = {
        .imageName = @"qm_balloon_left",
        .hexTintColor = @"#17d14b",
        .imageCapInsets = (UIEdgeInsets){7, 13, 8, 7},
    },
    
    .rightBalloon = {
        .imageName = @"qm_balloon_right",
        .imageCapInsets = (UIEdgeInsets){7, 7, 8, 13},
        .hexTintColor = @"#e2ebf2",
    },
};

UIFont * UIFontFromQMMessageLayout(QMMessageLayout layout) {
    
    return [UIFont fontWithName:layout.fontName size:layout.fontSize];
}