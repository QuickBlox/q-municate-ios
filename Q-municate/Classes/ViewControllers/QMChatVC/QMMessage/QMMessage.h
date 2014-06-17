//
//  QMMessage.h
//  Q-municate
//
//  Created by Andrey on 12.06.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QMMessageProtocol.h"
#import "QMChatLayoutConfigs.h"

@interface QMMessage : NSObject
/**
 * Message text
 */
@property (strong, nonatomic) QBChatHistoryMessage *data;

/**
 * Attributes for attributed message text
 */
@property (strong, nonatomic) NSDictionary *attributes;

/**
 * Default thumbnail(placeholder) for media.
 */
@property (strong, nonatomic) UIImage *thumbnail;


/**
 * Boolean value that indicates who is the sender
 * This is important property and will be used to decide in which side show message.
 */
@property (nonatomic) BOOL fromMe;

/**
 * Type of message.
 * Available values:
 * QMMessageTypeText, QMMessageTypePhoto
 */
@property (nonatomic) QMMessageType type;

@property (nonatomic, readonly) CGSize size;

@property (nonatomic) struct QMChatCellLayoutConfig layout;

@end
