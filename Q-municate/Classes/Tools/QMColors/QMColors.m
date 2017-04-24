//
//  QMColors.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 3/23/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMColors.h"

//MARK: - Table view

UIColor *QMTableViewBackgroundColor() {
    
    static UIColor *color = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        color = [UIColor colorWithRed:239.0f/255.0f green:239.0f/255.0f blue:244.0f/255.0f alpha:1.0f];
    });
    
    return color;
}

UIColor *QMVideoCallBackgroundColor() {
    
    static UIColor *color = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        color = [UIColor colorWithRed:46.0f/255.0f green:46.0f/255.0f blue:46.0f/255.0f alpha:1.0f];
    });
    
    return color;
}

//MARK: - Chat colors

UIColor *QMChatBackgroundColor() {
    
    static UIColor *color = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        color = [UIColor whiteColor];
    });
    
    return color;
}

UIColor *QMChatTopLabelColor() {
    
    static UIColor *color = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        color = [UIColor colorWithRed:0 green:122.0f/255.0f blue:1.0f alpha:1.0f];
    });
    
    return color;
}

UIColor *QMChatIncomingBottomLabelColor() {
    
    static UIColor *color = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        color = [UIColor colorWithWhite:0 alpha:0.4f];
    });
    
    return color;
}

UIColor *QMChatOutgoingBottomLabelColor() {
    
    static UIColor *color = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        color = [UIColor colorWithWhite:1.0f alpha:0.8f];
    });
    
    return color;
}

UIColor *QMChatCellHighlightedColor() {
    
    static UIColor *color = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        color = [UIColor colorWithWhite:0.5f alpha:0.5f];
    });
    
    return color;
}

UIColor *QMChatCellOutgoingHighlightedColor() {
    
    static UIColor *color = nil;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        float h, s, b, a;
        UIColor *outgoingCellColor = QMChatOutgoingCellColor();
        
        if ([outgoingCellColor getHue:&h saturation:&s brightness:&b alpha:&a]) {
            color = [UIColor colorWithHue:h
                               saturation:s
                               brightness:b * (float)0.75
                                    alpha:a];
        }
    });
    
    return color;
}


UIColor *QMChatCellIncomingHighlightedColor() {
    
    static UIColor *color = nil;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        float h, s, b, a;
        UIColor *incomingCellColor = QMChatIncomingCellColor();
        
        if ([incomingCellColor getHue:&h saturation:&s brightness:&b alpha:&a]) {
            color = [UIColor colorWithHue:h
                               saturation:s
                               brightness:b * (float)0.75
                                    alpha:a];
        }
    });
    
    return color;
}

UIColor *QMChatIncomingCellColor() {
    
    static UIColor *color = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        color = [UIColor colorWithRed:223.0f/255.0f green:227.0f/255.0f blue:229.0f/255.0f alpha:1.0f];
    });
    
    return color;
}

UIColor *QMChatOutgoingCellColor() {
    
    static UIColor *color = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        color = [UIColor colorWithRed:23.0f/255.0f green:208.0f/255.0f blue:75.0f/255.0f alpha:1.0f];
    });
    
    return color;
}

UIColor *QMChatOutgoingCellSendingColor() {
    
    static UIColor *color = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        color = [UIColor colorWithRed:0.761f green:0.772f blue:0.746f alpha:1.0f];
    });
    
    return color;
}

UIColor *QMChatOutgoingCellFailedColor() {
    
    static UIColor *color = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        color = [UIColor colorWithRed:1.0f green:0.19f blue:0.108f alpha:1.0f];
    });
    
    return color;
}

UIColor *QMChatNotificationCellColor() {
    
    static UIColor *color = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        color = [UIColor colorWithRed:242.0f/255.0f green:244.0f/255.0f blue:245.0f/255.0f alpha:1.0f];
    });
    
    return color;
}

UIColor *QMChatRedNotificationCellColor() {
    
    static UIColor *color = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        color = [UIColor colorWithRed:197.0f/255.0f green:144.0f/255.0f blue:128.0f/255.0f alpha:1.0f];
    });
    
    return color;
}

UIColor *QMChatEmojiiKeyboardTintColor() {
    
    static UIColor *color = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        color = [UIColor colorWithRed:0.678f green:0.762f blue:0.752f alpha:1.0f];
    });
    
    return color;
}

UIColor *QMChatIncomingLinkColor() {
    
    static UIColor *color = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        color = [UIColor colorWithRed:13.0f/255.0f green:112.0f/255.0f blue:179.0f/255.0f alpha:1.0f];
    });
    
    return color;
}
