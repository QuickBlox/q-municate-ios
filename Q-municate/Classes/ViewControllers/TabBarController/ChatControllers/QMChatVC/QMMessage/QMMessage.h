//
//  QMMessage.h
//  Q-municate
//
//  Created by Andrey Ivanov on 12.06.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QMChatLayoutConfigs.h"
#import "QMMessageType.h"

@interface QMMessage : QBChatHistoryMessage
/**
 * Attributes for attributed message text
 */
@property (strong, nonatomic) NSDictionary *attributes;
/**
 QBChatDialog
 */
@property (weak, nonatomic, readonly) QBChatDialog *chatDialog;
/**
 * Balloon image
 */
@property (strong, nonatomic, readonly) UIImage *balloonImage;
/**
 Ballon color (Load from layout property)
 */
@property (strong, nonatomic, readonly) UIColor *balloonColor;

- (UIColor *)textColor ;
/**
 This is important property
 */
@property (nonatomic) struct QMMessageLayout layout;
/**
 */
@property (nonatomic, readonly) QMChatBalloon balloonSettings;
/**
 Calculate and cached message size
 */
@property (nonatomic, readonly) CGSize messageSize;
/**
 * Type of message.
 * Available values:
 * QMMessageTypeText, QMMessageTypePhoto
 */
@property (nonatomic, readonly) QMMessageType type;

/**
 * WARNING! 
 * Only for notifications with notification type SEND. It means that it's contact request notification.
 */
@property (nonatomic, assign) BOOL marked;

/**
 * Align message container
 * Available values:
 * QMMessageContentAlignLeft, QMMessageContentAlignRight, QMMessageContentAlignCenter
 * This is important property and will be used to decide in which side show message.
 */
@property (nonatomic) QMMessageContentAlign align;
/**
 if -1 then minWidht getting from layout property
 */
@property (nonatomic) CGFloat minWidth;

@property (nonatomic, readonly) NSString *encodingText;

- (instancetype)initWithChatHistoryMessage:(QBChatAbstractMessage *)historyMessage;

@end
