//
//  QMColors.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 3/23/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMColors.h"

#pragma mark - Table view

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

#pragma mark - Chat colors

UIColor *QMChatBackgroundColor() {
    
    static UIColor *color = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        color = [UIColor colorWithRed:237.0f/255.0f green:230.0f/255.0f blue:211.0f/255.0f alpha:1.0f];
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

UIColor *QMChatOutgoingCellColor() {
    
    static UIColor *color = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        color = [UIColor colorWithRed:23.0f/255.0f green:208.0f/255.0f blue:75.0f/255.0f alpha:1.0f];
    });
    
    return color;
}

UIColor *QMChatNotificationCellColor() {
    
    static UIColor *color = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        color = [UIColor colorWithRed:188.0f/255.0f green:185.0f/255.0f blue:168.0f/255.0f alpha:1.0f];
    });
    
    return color;
}

UIColor *QMChatRedNotificationCellColor() {
    
    static UIColor *color = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        color = [UIColor colorWithRed:160.0f/255.0f green:0 blue:0 alpha:1.0f];
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
