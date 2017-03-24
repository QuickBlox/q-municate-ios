//
//  QBChatAttachment.h
//  Quickblox
//
//  Created by QuickBlox team on 08/05/2014.
//  Copyright (c) 2016 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Quickblox/QBNullability.h>
#import <Quickblox/QBGeneric.h>

@interface QBChatAttachment : NSObject <NSCoding, NSCopying>

/**
 *  Attachment name.
 */
@property (nonatomic, copy, nullable ) NSString *name;

/**
 *  Type of attachment.
 *
 *  @discussion Can be any type. For example: audio, video, image, location, any other
 */
@property (nonatomic, copy, nullable) NSString *type;

/**
 *  Content URL.
 */
@property (nonatomic, copy, nullable) NSString *url;

/**
 *  ID of attached element.
 */
@property (nonatomic, copy, nullable) NSString *ID;


/**
 *  Width of attachment (for video/image).
 */
@property (nonatomic, assign) NSUInteger width;

/**
 *  Height of attachment (for video/image).
 */
@property (nonatomic, assign) NSUInteger height;

/**
 *  Duration in seconds (for video/audio).
 */
@property (nonatomic, assign) double duration;

/**
 *  Size of attachment in bytes.
 */
@property (nonatomic, assign) NSUInteger size;

/**
 *  Any addictional data.
 */
@property (nonatomic, copy, nullable) NSString *data;

@end
