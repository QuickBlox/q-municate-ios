//
//  QBChatAttachment+QMCustomParameters.h
//  QMChatService
//
//  Created by Vitaliy Gurkovsky on 3/26/17.
//
//

#import <Quickblox/Quickblox.h>

typedef NS_ENUM(NSInteger, QMAttachmentContentType) {
    
    QMAttachmentContentTypeAudio = 1,
    QMAttachmentContentTypeVideo,
    QMAttachmentContentTypeImage,
    QMAttachmentContentTypeCustom
};

typedef NS_ENUM(NSUInteger, QMAttachmentStatus) {
    
    QMAttachmentStatusNotLoaded = 0,
    QMAttachmentStatusLoading,
    QMAttachmentStatusLoaded,
    QMAttachmentStatusPreparing,
    QMAttachmentStatusPrepared,
    QMAttachmentStatusError
};

@interface QBChatAttachment (QMCustomParameters)

@property (assign, nonatomic) QMAttachmentContentType contentType;

@property (assign, nonatomic) QMAttachmentStatus status;

/**
 *  The URL that identifies locally saved attachment resource.
 */
@property (copy, nonatomic) NSURL *localFileURL;

/**
 *  Data representation of attachment.
 */
@property (strong, nonatomic) NSData *mediaData;

/**
 *  Image of attachment (for video/image).
 */
@property (strong, nonatomic) UIImage *image;

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
@property (nonatomic, assign) NSInteger duration;

/**
 *  Size of attachment in bytes.
 */
@property (nonatomic, assign) NSUInteger size;


- (NSURL *)remoteURL;
- (NSString *)stringContentType;
- (NSString *)stringMIMEType;
- (NSString *)extension;

@end
