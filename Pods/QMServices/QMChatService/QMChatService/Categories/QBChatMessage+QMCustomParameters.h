//
//  QBChatAbstractMessage+QMCustomParameters.h
//  QMServices
//
//  Created by Andrey Ivanov on 24.07.14.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import "QMChatTypes.h"
#import "QBChatAttachment+QMCustomParameters.h"
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QBChatMessage (QMCustomParameters)

/**
 *  Message
 */
@property (strong, nonatomic, nullable) NSString *saveToHistory;
@property (assign, nonatomic) QMMessageType messageType;
@property (strong, nonatomic, nullable) NSString *chatMessageID;
@property (assign, nonatomic) BOOL messageDeliveryStatus;
@property (assign, nonatomic) QMMessageAttachmentStatus attachmentStatus;
@property (assign, nonatomic) CLLocationCoordinate2D locationCoordinate;


/**
 *  Dialog
 */
@property (strong, nonatomic, readonly, nullable) QBChatDialog *dialog;
@property (assign, nonatomic) QMDialogUpdateType dialogUpdateType;
@property (strong, nonatomic, nullable) NSArray<NSNumber *> *currentOccupantsIDs;
@property (strong, nonatomic, nullable) NSArray<NSNumber *> *addedOccupantsIDs;
@property (strong, nonatomic, nullable) NSArray<NSNumber *> *deletedOccupantsIDs;
@property (strong, nonatomic, nullable) NSString *dialogName;
@property (strong, nonatomic, nullable) NSString *dialogPhoto;
@property (strong, nonatomic, nullable) NSDate *dialogUpdatedAt;

/**
 *  Save values from QBChatDialog to message custom parameters
 *
 *  @param dialog QBChatDialog that will be saved
 */
- (void)updateCustomParametersWithDialog:(QBChatDialog *)dialog;

/**
 *  This method is used to determine if the message data item contains text or media.
 *  If this method returns `YES`, an instance of `QMChatViewController` will ignore
 *  the `text` method of this protocol when dequeuing a `QMChatCollectionViewCell`
 *  and only call the `media` method.
 *
 *  Similarly, if this method returns `NO` then the `media` method will be ignored and
 *  and only the `text` method will be called.
 *
 *  @return A boolean value specifying whether or not this is a media message or a text message.
 *  Return `YES` if this item is a media message, and `NO` if it is a text message.
 */
- (BOOL)isMediaMessage;

/**
 *  This method is used to determine if the message data item is notification.
 *
 *  @return A boolean value specifying whether or not this is a notification message.
 *  Return `YES` if this item is a notification message, and `NO` if it is a text message.
 */
- (BOOL)isNotificationMessage;

/**
 *  This method is used to determine if the message data item is location.
 *
 *  @return A boolean value specifying whether or not this is a location message.
 *  Return `YES` if this item is a location message, and `NO` if it is a text message.
 */
- (BOOL)isLocationMessage;

/**
 *  This method is used to determine if the message data item is audio attachment.
 *
 *  @return A boolean value specifying whether or not this is a message with audio attachment.
 *  Return `YES` if this item is a audio attachment, and `NO` if it is a text message.
 */
- (BOOL)isAudioAttachment;

/**
 *  This method is used to determine if the message data item is video attachment.
 *
 *  @return A boolean value specifying whether or not this is a message with video attachment.
 *  Return `YES` if this item is a video attachment, and `NO` if it is a text message.
 */
- (BOOL)isVideoAttachment;

/**
 *  This method is used to determine if the message data item is image attachment.
 *
 *  @return A boolean value specifying whether or not this is a message with image attachment.
 *  Return `YES` if this item is a image attachment, and `NO` if it is a text message.
 */
- (BOOL)isImageAttachment;


@end

NS_ASSUME_NONNULL_END
