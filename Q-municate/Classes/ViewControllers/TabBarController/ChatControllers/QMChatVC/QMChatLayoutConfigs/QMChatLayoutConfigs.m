//
//  QMChatLayoutConfigs.m
//  Q-municate
//
//  Created by Andrey Ivanov on 13.06.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMChatLayoutConfigs.h"

const CGFloat kQMMessageMaxWidth = 310;
const CGFloat kQMMessageMinWidth = 150;

struct QMChatBalloon QMChatBalloonNull = {
    
    .imageName = @"",
    .hexTintColor = @"",
    .imageCapInsets= (UIEdgeInsets){0, 0, 0, 0},
};

struct QMMessageLayout QMMessageQmunicateLayout = {
    
    .messageMargin = {
        .top = 15,
        .left = 5,
        .bottom = 5,
        .right = 5,
    },
    .titleHeight = 13,
    .messageMaxWidth = kQMMessageMaxWidth,
    .messageMinWidth = kQMMessageMinWidth,
    .userImageSize = (CGSize){50, 50},
    
    .fontName = @"HelveticaNeue",
    .fontSize = 16,

    .leftBalloon = {
        .imageName = @"qm_balloon_left",
        .imageCapInsets= (UIEdgeInsets){7, 13, 8, 7},
        .hexTintColor = @"#e2ebf2",
        .textColor = @"#000"
    },
    
    .rightBalloon = {
        .imageName = @"qm_balloon_right",
        .imageCapInsets = (UIEdgeInsets){7, 7, 8, 13},
        .hexTintColor = @"#17d14b",
        .textColor = @"#FFFFFF"
    },
};

struct QMMessageLayout QMMessageBubbleLayout = {
    .messageMargin = {
        .top = 5,
        .left = 5,
        .bottom = 5,
        .right = 5,
    },
    .titleHeight = 13,
    .messageMaxWidth = kQMMessageMaxWidth,
    .messageMinWidth = kQMMessageMinWidth,
    .userImageSize = (CGSize){50, 50},
    
    .fontName = @"HelveticaNeue",
    .fontSize = 16,
    
    .leftBalloon = {
        .imageName = @"qm_balloon_left",
        .imageCapInsets= (UIEdgeInsets){7, 13, 8, 7},
        .hexTintColor = @"#e2ebf2",
        .textColor = @"#000"
    },
    
    .rightBalloon = {
        .imageName = @"qm_balloon_right",
        .imageCapInsets = (UIEdgeInsets){7, 7, 8, 13},
        .hexTintColor = @"#17d14b",
        .textColor = @"#FFFFFF"
    },
};

struct QMMessageLayout QMMessageAttachmentLayout = {
    
    .messageMargin = {
        .top = 15,
        .left = 5,
        .bottom = 5,
        .right = 5,
    },
    
    .messageMaxWidth = kQMMessageMaxWidth,

    .userImageSize = (CGSize){50,50},
    
    .fontName = @"HelveticaNeue-Light",
    .fontSize = 16,
    
    .leftBalloon = {
        .imageName = @"qm_balloon_left",
        .imageCapInsets= (UIEdgeInsets){7, 13, 8, 7},
        .hexTintColor = @"#e2ebf2",
        .textColor = @"#000"
    },
    
    .rightBalloon = {
        .imageName = @"qm_balloon_right",
        .imageCapInsets = (UIEdgeInsets){7, 7, 8, 13},
        .hexTintColor = @"#17d14b",
        .textColor = @"#FFFFFF"
    },
};

UIFont * UIFontFromQMMessageLayout(QMMessageLayout layout) {
    
    return [UIFont fontWithName:layout.fontName size:layout.fontSize];
}