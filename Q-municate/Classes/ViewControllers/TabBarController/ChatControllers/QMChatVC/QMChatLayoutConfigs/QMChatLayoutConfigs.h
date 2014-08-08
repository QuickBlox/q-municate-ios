//
//  QMChatLayoutConfigs.h
//  Q-municate
//
//  Created by Andrey Ivanov on 13.06.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, QMMessageContentAlign) {
    
    QMMessageContentAlignLeft,
    QMMessageContentAlignRight,
    QMMessageContentAlignCenter
};

typedef struct QMChatBalloon {
    
    __unsafe_unretained NSString *imageName;
    __unsafe_unretained NSString *hexTintColor;
    __unsafe_unretained NSString *textColor;
    UIEdgeInsets imageCapInsets;
    
} QMChatBalloon ;

QMChatBalloon QMChatBalloonNull;

/**
 Message layout stucture
 */
typedef struct QMMessageLayout {
    
    UIEdgeInsets messageMargin;
    
    CGFloat messageMaxWidth;
    CGFloat messageMinWidth;
    CGFloat titleHeight;
    
    CGSize contentSize;
    
    CGSize userImageSize;
    
    CGFloat fontSize;
    __unsafe_unretained NSString *fontName;
    
    QMChatBalloon leftBalloon;
    QMChatBalloon rightBalloon;
    
    
} QMMessageLayout;

/**
 Examples Of Themes
 QMMessageQmunicateLayout - default theme
 QMMessageBubbleLayout - bubble thme
 */

QMMessageLayout QMMessageQmunicateLayout;
QMMessageLayout QMMessageBubbleLayout;
QMMessageLayout QMMessageAttachmentLayout;

UIFont * UIFontFromQMMessageLayout(QMMessageLayout layout);
