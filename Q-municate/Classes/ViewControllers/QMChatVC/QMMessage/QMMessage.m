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
#import "UIColor+Hex.h"

typedef NS_ENUM(NSUInteger, QMChatNotificationsType) {
    
    QMChatNotificationsTypeNone,
    QMChatNotificationsTypeRoomCreated,
    QMChatNotificationsTypeRoomUpdated,
};

NSString *const kQMNotificationTypeKey = @"notification_type";

@interface QMMessage()

@property (assign, nonatomic) CGSize messageSize;
@property (assign, nonatomic) QMMessageType type;
@property (strong, nonatomic) UIImage *balloonImage;
@property (strong, nonatomic) UIColor *balloonColor;

@end

@implementation QMMessage

- (void)setData:(QBChatHistoryMessage *)data {
    
    NSAssert([QBChatHistoryMessage class], @"Check it");
    _data = data;
    
    NSNumber *notificationType = data.customParameters[kQMNotificationTypeKey];
    
    if (data.attachments.count > 0) {
        
        self.type = QMMessageTypePhoto;
        self.layout = QMMessageAttachmentLayout;
        
    } else if (notificationType) {
        
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:@"Need update it"
                                     userInfo:@{}];
        
        self.type = QMMessageTypeSystem;
        
    } else {
        
        self.type = QMMessageTypeText;
        self.layout = QMMessageQmunicateLayout;
    }
}

- (CGSize)calculateMessageSize {
    
    QMMessageLayout layout = self.layout;
    QMChatBalloon balloon = self.balloonSettings;
    UIEdgeInsets insets = balloon.imageCapInsets;
    CGSize contentSize = CGSizeZero;
    /**
     Calculate content size
     */
    if (self.type == QMMessageTypePhoto) {
        
        contentSize = CGSizeMake(100, 100);
        
    } else if (self.type == QMMessageTypeText) {
        
        UIFont *font = UIFontFromQMMessageLayout(self.layout);

        CGFloat textWidth = layout.messageMaxWidth - layout.userImageSize.width - insets.left - insets.right;
        
        contentSize = [self.data.text usedSizeForMaxWidth:textWidth
                                                     font:font
                                           withAttributes:self.attributes];
        if (layout.messageMinWidth > 0) {
            if (contentSize.width < layout.messageMinWidth) {
                contentSize.width = layout.messageMinWidth;
            }
        }
    }
    
    layout.contentSize = contentSize;   //Set Content size
    self.layout = layout;               //Save Content size for reuse
    
    /**
     *Calculate message size
     */
    CGSize messageSize = contentSize;
    
    messageSize.height += layout.messageMargin.top + layout.messageMargin.bottom + insets.top + insets.bottom;
    messageSize.width += layout.messageMargin.left + layout.messageMargin.right;
    
    if (!CGSizeEqualToSize(layout.userImageSize, CGSizeZero)) {
        if (messageSize.height - (layout.messageMargin.top + layout.messageMargin.bottom) < layout.userImageSize.height) {
            messageSize.height = layout.userImageSize.height + layout.messageMargin.top + layout.messageMargin.bottom;
        }
    }
    
    return messageSize;
}

- (CGSize)messageSize {
    
    if (CGSizeEqualToSize(_messageSize, CGSizeZero)) {
        
        _messageSize = [self calculateMessageSize];
    }
    
    return _messageSize;
}

- (UIImage *)balloonImage {

    if (!_balloonImage) {

        NSAssert(self, @"Check it");
        
        QMChatBalloon balloon = [self balloonSettings];
        
        NSString *imageName = balloon.imageName;
        UIImage *balloonImage = [UIImage imageNamed:imageName];
        
        balloonImage = [balloonImage resizableImageWithCapInsets:balloon.imageCapInsets];
        _balloonImage = [balloonImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    return _balloonImage;
}

- (QMChatBalloon)balloonSettings {
    
    if (self.align == QMMessageContentAlignLeft) {
        return self.layout.leftBalloon;
    } else if (self.align == QMMessageContentAlignRight) {
        return self.layout.rightBalloon;
    }
    
    return QMChatBalloonNull;
}

- (UIColor *)balloonColor {

    if (!_balloonColor) {
        
        QMChatBalloon balloonSettings = [self balloonSettings];
        NSString *hexString = balloonSettings.hexTintColor;
        
        if (hexString.length > 0) {
            
            UIColor *color = [UIColor colorWithHexString:hexString];
            NSAssert(color, @"Check it");
            
            _balloonColor = color;
        }
    }
    
    return _balloonColor;
}

@end
