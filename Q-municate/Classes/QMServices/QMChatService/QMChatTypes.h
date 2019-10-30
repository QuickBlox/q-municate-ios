//
//  QMChatTypes.h
//  QMServices
//
//  Created by Injoit on 29.04.15.
//  Copyright © 2015 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, QMMessageType) {
    /** Default message type*/
    QMMessageTypeText = 0,
    QMMessageTypeCreateGroupDialog = 1,
    QMMessageTypeUpdateGroupDialog = 2,
    
    QMMessageTypeContactRequest = 4,
    QMMessageTypeAcceptContactRequest,
    QMMessageTypeRejectContactRequest,
    QMMessageTypeDeleteContactRequest
};

typedef NS_ENUM(NSUInteger, QMDialogUpdateType) {
    QMDialogUpdateTypeNone      = 0,
    QMDialogUpdateTypePhoto     = 1,
    QMDialogUpdateTypeName      = 2,
    QMDialogUpdateTypeOccupants = 3
};

/**
 The current status of the attachment message.
 */
typedef NS_ENUM(NSUInteger, QMMessageAttachmentStatus) {
    /** Default attachment state. Attachment has no active processes */
    QMMessageAttachmentStatusNotLoaded = 0,
    /** The attachment has started the download process. */
    QMMessageAttachmentStatusLoading,
    /** The attachment has started the upload process. */
    QMMessageAttachmentStatusUploading,
    /** The attachment has started the asset-loading process. */
    QMMessageAttachmentStatusPreparing,
    /** The attachment process has been completed successfully. */
    QMMessageAttachmentStatusLoaded,
    /** The attachment process failed because of an error. */
    QMMessageAttachmentStatusError
};
