//
//  QMMessage.m
//  Q-municate
//
//  Created by Andrey Ivanov on 12.06.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMMessage.h"
#import "QMChatLayoutConfigs.h"
#import "NSString+UsedSize.h"
#import "UIColor+Hex.h"
#import "SDImageCache.h"
#import "UIImage+TintColor.h"

#define SYSTEM_MESSAGE_SIZE CGSizeMake(320.0f, 60.0f)


typedef NS_ENUM(NSUInteger, QMChatNotificationsType) {
    
    QMChatNotificationsTypeNone,
    QMChatNotificationsTypeRoomCreated,
    QMChatNotificationsTypeRoomUpdated,
};

NSString *const kQMNotificationTypeKey = @"notification_type";


@interface QMMessage()

@property (assign, nonatomic) CGSize messageSize;
@property (assign, nonatomic) QMMessageType type;
@property (strong, nonatomic) UIColor *balloonColor;
@property (weak, nonatomic) QBChatDialog *chatDialog;

@end

@implementation QMMessage


- (instancetype)initWithChatHistoryMessage:(QBChatAbstractMessage *)historyMessage {
    
    self = [super init];
    if (self) {
        
        self.minWidth = -1;
        self.text = historyMessage.encodedText;
        self.ID = historyMessage.ID;
        self.recipientID = historyMessage.recipientID;
        self.senderID = historyMessage.senderID;
        self.datetime = historyMessage.datetime;
        self.customParameters = historyMessage.customParameters;
        self.attachments = historyMessage.attachments;
        
//        self.chatDialog = [[QMApi instance] chatDialogWithID:historyMessage.cParamDialogID];
        self.cParamNotificationType = historyMessage.cParamNotificationType;
        if (self.cParamNotificationType > 0 && self.cParamNotificationType != QMMessageNotificationTypeDeliveryMessage) {
            self.type = QMMessageTypeSystem;
            return self;
        }
        
        if (self.attachments.count > 0) {
            
            self.type = QMMessageTypePhoto;
            self.layout = QMMessageAttachmentLayout;
            
        }
//        else if (notificationType) {
////            @throw [NSException exceptionWithName:NSInternalInconsistencyException
////                                           reason:@"Need update it"
////                                         userInfo:@{}];
//            self.layout = QMMessageBubbleLayout;
//            self.type = QMMessageTypeSystem;
//            
//        }
        else {
            
            self.type = QMMessageTypeText;
            self.layout = QMMessageQmunicateLayout;
        }
        
    }
    return self;
}

- (CGSize)calculateMessageSize {
    
    QMMessageLayout layout = self.layout;
    QMChatBalloon balloon = self.balloonSettings;
    UIEdgeInsets insets = balloon.imageCapInsets;
    CGSize contentSize = CGSizeZero;
    /**
     Calculate content size
     */
    if (self.minWidth > 0) {
        layout.messageMinWidth = self.minWidth;
    }
    
    if (self.type == QMMessageTypePhoto) {
        
        contentSize = CGSizeMake(200, 200);
        
    } else if (self.type == QMMessageTypeText) {
        
        UIFont *font = UIFontFromQMMessageLayout(self.layout);
        
        CGFloat textWidth =
        layout.messageMaxWidth - layout.userImageSize.width - insets.left - insets.right - layout.messageMargin.right - layout.messageMargin.left;
        
        contentSize = [self.text usedSizeForWidth:textWidth
                                             font:font
                                   withAttributes:self.attributes];
        
    }
    
    layout.contentSize = contentSize;   //Set Content size
    self.layout = layout;               //Save Content size for reuse
    
    /**
     *Calculate message size
     */
    CGSize messageSize = contentSize;
    
    messageSize.height += layout.messageMargin.top + layout.messageMargin.bottom + insets.top + insets.bottom + layout.titleHeight;
    messageSize.width += layout.messageMargin.left + layout.messageMargin.right;
    
    if (!CGSizeEqualToSize(layout.userImageSize, CGSizeZero)) {
        if (messageSize.height - (layout.messageMargin.top + layout.messageMargin.bottom) < layout.userImageSize.height) {
            messageSize.height = layout.userImageSize.height + layout.messageMargin.top + layout.messageMargin.bottom;
        }
    }
    
    return messageSize;
}

- (CGSize)messageSize {
    
    if (self.type == QMMessageTypeSystem) {
        return SYSTEM_MESSAGE_SIZE;
    }
    if (CGSizeEqualToSize(_messageSize, CGSizeZero)) {
        
        _messageSize = [self calculateMessageSize];
    }
    
    return _messageSize;
}

- (UIImage *)balloonImage {
    
    QMChatBalloon balloon = [self balloonSettings];
    
    UIImage *balloonImage = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:balloon.imageName];
    
    if (!balloonImage) {
        
        balloonImage = [UIImage imageNamed:balloon.imageName];
        balloonImage = [balloonImage tintImageWithColor:self.balloonColor];
        balloonImage = [balloonImage resizableImageWithCapInsets:balloon.imageCapInsets];
        [[SDImageCache sharedImageCache]  storeImage:balloonImage forKey:balloon.imageName toDisk:NO];
    }

    return balloonImage;
}

- (QMChatBalloon)balloonSettings {
    
    if (self.align == QMMessageContentAlignLeft) {
        return self.layout.leftBalloon;
    } else if (self.align == QMMessageContentAlignRight) {
        return self.layout.rightBalloon;
    }
    
    return QMChatBalloonNull;
}

- (UIColor *)textColor {
    
    QMChatBalloon balloonSettings = [self balloonSettings];
    NSString *hexString = balloonSettings.textColor;
    
    if (hexString.length > 0) {
        
        UIColor *color = [UIColor colorWithHexString:hexString];
        NSAssert(color, @"Check it");
        return color;
    }
    
    return nil;
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
