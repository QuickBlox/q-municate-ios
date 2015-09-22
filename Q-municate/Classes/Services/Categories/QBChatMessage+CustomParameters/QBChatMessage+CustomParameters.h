//
//  QBChatMessage+CustomParameters.h
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 9/22/15.
//  Copyright © 2015 Quickblox. All rights reserved.
//

#import <Quickblox/Quickblox.h>

typedef NS_ENUM(NSUInteger, QMMessageNotificationType) {
    QMMessageNotificationTypeNone,
    QMMessageNotificationTypeCreateGroupDialog,
    QMMessageNotificationTypeUpdateGroupDialog,
    QMMessageNotificationTypeDeliveryMessage,
    
    QMMessageNotificationTypeSendContactRequest,
    QMMessageNotificationTypeConfirmContactRequest,
    QMMessageNotificationTypeRejectContactRequest,
    QMMessageNotificationTypeDeleteContactRequest
};

@interface QBChatMessage (CustomParameters)

@property (strong, nonatomic) NSString *cParamSaveToHistory;
@property (assign, nonatomic) QMMessageNotificationType cParamNotificationType;
@property (strong, nonatomic) NSString *cParamChatMessageID;
@property (strong, nonatomic) NSNumber *cParamDateSent;
@property (assign, nonatomic) BOOL cParamMessageDeliveryStatus;

@property (strong, nonatomic) NSString *cParamDialogID;
@property (strong, nonatomic) NSString *cParamRoomJID;
@property (strong, nonatomic) NSString *cParamDialogRoomName;
@property (strong, nonatomic) NSString *cParamDialogRoomPhoto;
@property (strong, nonatomic) NSNumber *cParamDialogType;
@property (strong, nonatomic) NSArray *cParamDialogOccupantsIDs;
@property (strong, nonatomic) NSNumber *cParamDialogDeletedID;

- (void)setCustomParametersWithChatDialog:(QBChatDialog *)chatDialog;
- (QBChatDialog *)chatDialogFromCustomParameters;

@end
