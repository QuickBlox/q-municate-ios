//
//  QMMessage.m
//  Q-municate
//
//  Created by Andrey on 12.06.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMMessage.h"
#import "QMChatLayoutConfigs.h"
#import "NSString+UsedSize.h"

@implementation QMMessage

@synthesize data = data;
@synthesize attributes = _attributes;
@synthesize thumbnail = _thumbnail;
@synthesize fromMe = _fromMe;
@synthesize type = _type;
@synthesize layout = _layout;
@synthesize size = _size;

- (CGSize)calculateSize {
    
    UIFont *font = [UIFont fontWithName:self.layout.fontName
                                   size:self.layout.fontSize];
    
    
    QMChatCellLayoutConfig layout = self.layout;
    
    if (self.attributes) {
        layout.textSize = [self.data.text usedSizeForMaxWidth:self.layout.messageMaxWidth
                                               withAttributes:self.attributes];
    } else {
        layout.textSize = [self.data.text usedSizeForMaxWidth:self.layout.messageMaxWidth
                                                     withFont:font];
    }
    
    self.layout = layout;
    
    CGSize size = layout.textSize;
    
    if (self.layout.balloonMinWidth) {
        
        CGFloat messageMinWidth = self.layout.balloonMinWidth - self.layout.balloonMinHeight - self.layout.messageRightMargin;
        
        
        if (size.width <  messageMinWidth) {
            size.width = messageMinWidth;
            
            CGSize newSize = [self.data.text usedSizeForMaxWidth:messageMinWidth
                                                        withFont:font];
            
            if (self.attributes) {
                newSize = [self.data.text usedSizeForMaxWidth:messageMinWidth
                                               withAttributes:self.attributes];
            }
            
            size.height = newSize.height;
        }
    }
    
//    CGFloat messageMinHeight = self.layout.balloonMinHeight - self.layout.messageTopMargin + self.layout.messageBottomMargin;
//    
//    if (self.layout.balloonMinHeight && size.height < messageMinHeight) {
//        size.height = messageMinHeight;
//    }
    
    size.height += self.layout.messageTopMargin + self.layout.messageBottomMargin;
    
    if (!CGSizeEqualToSize(self.layout.userImageSize, CGSizeZero)) {
        
        if (size.height < self.layout.userImageSize.height) {
            size.height = self.layout.userImageSize.height;
        }
    }
    
    CGFloat height = size.height + self.layout.balloonTopMargin + self.layout.balloonBottomMargin;
    
    return CGSizeMake(size.width, height);
}

- (CGSize)size {
    
    if (CGSizeEqualToSize(_size, CGSizeZero)) {
        
        _size = [self calculateSize];
    }
    
    return _size;
}

@end
