//
//  QMChatAttachmentService.h
//  QMServices
//
//  Created by Injoit on 7/1/15.
//  Copyright (c) 2015 Quickblox Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QMChatTypes.h"

@class QMChatService;
@class QMChatAttachmentService;
@class QMMediaService;

NS_ASSUME_NONNULL_BEGIN

@protocol QMChatAttachmentServiceDelegate <NSObject>

/**
 *  Is called when attachment service did change attachment status for some message.
 *  Please see QMMessageAttachmentStatus for additional info.
 *
 *  @param chatAttachmentService instance QMChatAttachmentService
 *  @param status new status
 *  @param message new status owner QBChatMessage
 */
- (void)chatAttachmentService:(QMChatAttachmentService *)chatAttachmentService didChangeAttachmentStatus:(QMMessageAttachmentStatus)status forMessage:(QBChatMessage *)message;

/**
 *  Is called when chat attachment service did change loading progress for some attachment.
 *  Used for display loading progress.
 *
 *  @param chatAttachmentService instance QMChatAttachmentService
 *  @param progress changed value of progress min 0.0, max 1.0
 *  @param attachment loaded QBChatAttachment
 */
- (void)chatAttachmentService:(QMChatAttachmentService *)chatAttachmentService didChangeLoadingProgress:(CGFloat)progress forChatAttachment:(QBChatAttachment *)attachment;

/**
 *  Is called when chat attachment service did change Uploading progress for attachment in message.
 *  Used for display loading progress.
 *
 *  @param chatAttachmentService QMChatAttachmentService instance
 *  @param progress              changed value of progress min 0.0, max 1.0
 *  @param messageID             ID of message that contains attachment
 */
- (void)chatAttachmentService:(QMChatAttachmentService *)chatAttachmentService didChangeUploadingProgress:(CGFloat)progress forMessage:(QBChatMessage *)message;

@optional

- (void)chatAttachmentService:(QMChatAttachmentService *)chatAttachmentService didChangeLoadingProgress:(CGFloat)progress forMessage:(QBChatMessage *)message attachment:(QBChatAttachment *)attachment;

@end

/**
 *  Chat attachment service
 */
@interface QMChatAttachmentService : NSObject

@property (nonatomic, strong) QMMediaService *mediaService;


/**
 *  Add delegate (Multicast)
 *
 *  @param delegate Instance confirmed QMChatServiceDelegate protocol
 */
- (void)addDelegate:(id <QMChatAttachmentServiceDelegate>)delegate;

/**
 *  Remove delegate from observed list
 *
 *  @param delegate Instance confirmed QMChatServiceDelegate protocol
 */
- (void)removeDelegate:(id <QMChatAttachmentServiceDelegate>)delegate;

/**
 *  Chat attachment service delegate
 *
 *  @warning *Deprecated in QMServices 0.4.7:* Use 'addDelegate:' instead.
 */
@property (nonatomic, weak, nullable) id<QMChatAttachmentServiceDelegate> delegate DEPRECATED_MSG_ATTRIBUTE("Deprecated in 0.4.7. Use 'addDelegate:' instead.");

/**
 *  Upload and send attachment message to dialog.
 *
 *  @param message      QBChatMessage instance
 *  @param dialog       QBChatDialog instance
 *  @param chatService  QMChatService instance
 *  @param image        Attachment image
 *  @param completion   Send message result
 *
 *  @warning *Deprecated in QMServices 0.4.7:* Use 'uploadAndSendAttachmentMessage:toDialog:withChatService:attachment:completion:' instead.
 */
- (void)uploadAndSendAttachmentMessage:(QBChatMessage *)message
                              toDialog:(QBChatDialog *)dialog
                       withChatService:(QMChatService *)chatService
                     withAttachedImage:(UIImage *)image
                            completion:(nullable QBChatCompletionBlock)completion DEPRECATED_MSG_ATTRIBUTE("Deprecated in 0.4.7. Use 'uploadAndSendAttachmentMessage:toDialog:withChatService:attachment:completion:' instead.");;

/**
 *  Get image by attachment message.
 *
 *  @param attachmentMessage      message with attachment
 *  @param completion             fetched image or error if failed
 *
 *  @warning *Deprecated in QMServices 0.4.4:* Use 'imageForAttachmentMessage:completion:' instead.
 */
- (void)getImageForAttachmentMessage:(QBChatMessage *)attachmentMessage completion:(nullable void(^)(NSError * _Nullable error, UIImage * _Nullable image))completion DEPRECATED_MSG_ATTRIBUTE("Deprecated in 0.4.4. Use 'imageForAttachmentMessage:completion:' instead.");


/**
 *  Get image by attachment message.
 *
 *  @param attachmentMessage message with attachment
 *  @param completion        fetched image or error if failed
 */
- (void)imageForAttachmentMessage:(QBChatMessage *)attachmentMessage
                       completion:(nullable void(^)(NSError * _Nullable error, UIImage * _Nullable image))completion;

/**
 *  Get image local image by attachment message.
 *
 *  @param attachmentMessage      message with attachment
 *  @param completion             local image or nil if no image
 */
- (void)localImageForAttachmentMessage:(QBChatMessage *)attachmentMessage
                            completion:(nullable void(^)(NSError * _Nullable error, UIImage * _Nullable image))completion;

//MARK: - Media

/**
 *  Upload and send attachment message to dialog.
 *
 *  @param message      QBChatMessage instance
 *  @param dialog       QBChatDialog instance
 *  @param chatService  QMChatService instance
 *  @param attachment   QBChatAttachment instance
 *  @param completion   Send message result
 */

- (void)uploadAndSendAttachmentMessage:(QBChatMessage *)message
                              toDialog:(QBChatDialog *)dialog
                       withChatService:(QMChatService *)chatService
                            attachment:(QBChatAttachment *)attachment
                            completion:(nullable QBChatCompletionBlock)completion;

@end

NS_ASSUME_NONNULL_END
