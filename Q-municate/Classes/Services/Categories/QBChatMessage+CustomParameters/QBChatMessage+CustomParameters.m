//
//  QBChatMessage+CustomParameters.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 9/22/15.
//  Copyright © 2015 Quickblox. All rights reserved.
//

/*Message keys*/
NSString const *kQMCustomParameterSaveToHistory = @"save_to_history";
NSString const *kQMCustomParameterNotificationType = @"notification_type";
NSString const *kQMCustomParameterChatMessageID = @"chat_message_id";
NSString const *kQMCustomParameterDateSent = @"date_sent";
NSString const *kQMCustomParameterChatMessageDeliveryStatus = @"message_delivery_status_read";
/*Dialogs keys*/
NSString const *kQMCustomParameterDialogID = @"dialog_id";
NSString const *kQMCustomParameterRoomJID = @"room_jid";
NSString const *kQMCustomParameterDialogRoomName = @"room_name";
NSString const *kQMCustomParameterDialogRoomPhoto = @"room_photo";
NSString const *kQMCustomParameterDialogType = @"type";
NSString const *kQMCustomParameterDialogOccupantsIDs = @"occupants_ids";
NSString const *kQMCustomParameterDialogDeletedID = @"deleted_id";

@interface QBChatMessage (Context)

@property (strong, nonatomic) NSMutableDictionary *context;

@end

@implementation QBChatMessage (CustomParameters)

/*Message params*/
@dynamic cParamSaveToHistory;
@dynamic cParamNotificationType;
@dynamic cParamChatMessageID;
@dynamic cParamDateSent;
@dynamic cParamMessageDeliveryStatus;

/*dialog info params*/
@dynamic cParamDialogID;
@dynamic cParamRoomJID;
@dynamic cParamDialogRoomName;
@dynamic cParamDialogType;
@dynamic cParamDialogOccupantsIDs;
@dynamic cParamDialogRoomPhoto;
@dynamic cParamDialogDeletedID;

- (NSMutableDictionary *)context {
    
    if (!self.customParameters) {
        self.customParameters = [NSMutableDictionary dictionary];
    }
    return self.customParameters;
}

#pragma mark - cParamChatMessageID

- (void)setCParamChatMessageID:(NSString *)cParamChatMessageID {
    self.context[kQMCustomParameterChatMessageID] = cParamChatMessageID;
}

- (NSString *)cParamChatMessageID {
    
    return self.context[kQMCustomParameterChatMessageID];
}

#pragma mark - cParamDateSent

- (void)setCParamDateSent:(NSNumber *)cParamDateSent {
    self.context[kQMCustomParameterDateSent] = cParamDateSent;
}

- (NSNumber *)cParamDateSent {
    return self.context[kQMCustomParameterDateSent];
}

#pragma mark - cParamDialogID

- (void)setCParamDialogID:(NSString *)cParamDialogID {
    self.context[kQMCustomParameterDialogID] = cParamDialogID;
}

- (NSString *)cParamDialogID {
    return self.context[kQMCustomParameterDialogID];
}

#pragma mark - cParamSaveToHistory

- (void)setCParamSaveToHistory:(NSString *)cParamSaveToHistory {
    self.context[kQMCustomParameterSaveToHistory] = cParamSaveToHistory;
}

- (NSString *)cParamSaveToHistory {
    return self.context[kQMCustomParameterSaveToHistory];
}

#pragma mark - cParamRoomJID

- (void)setCParamRoomJID:(NSString *)cParamRoomJID {
    self.context[kQMCustomParameterRoomJID] = cParamRoomJID;
}

- (NSString *)cParamRoomJID {
    return self.context[kQMCustomParameterRoomJID];
}

#pragma mark - cParamDialogType

- (void)setCParamDialogType:(NSNumber *)cParamDialogType {
    self.context[kQMCustomParameterDialogType] = cParamDialogType;
}

- (NSNumber *)cParamDialogType {
    return self.context[kQMCustomParameterDialogType];
}

#pragma mark - cParamDialogRoomName

- (void)setCParamDialogRoomName:(NSString *)cParamDialogRoomName {
    self.context[kQMCustomParameterDialogRoomName] = cParamDialogRoomName;
}

- (NSString *)cParamDialogRoomName {
    return self.context[kQMCustomParameterDialogRoomName];
}

#pragma mark - cParamDialogRoomPhoto

- (void)setCParamDialogRoomPhoto:(NSString *)cParamDialogRoomPhoto
{
    self.context[kQMCustomParameterDialogRoomPhoto] = cParamDialogRoomPhoto;
}

- (NSString *)cParamDialogRoomPhoto
{
    return self.context[kQMCustomParameterDialogRoomPhoto];
}

#pragma mark - cParamDialogDeletedID

- (void)setCParamDialogDeletedID:(NSNumber *)cParamDialogDeletedID
{
    self.context[kQMCustomParameterDialogDeletedID] = cParamDialogDeletedID;
}

-(NSNumber *)cParamDialogDeletedID
{
    return self.context[kQMCustomParameterDialogDeletedID];
}

#pragma mark - cParamDialogOccupantsIDs

- (void)setCParamDialogOccupantsIDs:(NSArray *)cParamDialogOccupantsIDs {
    
    NSString *strIDs = [cParamDialogOccupantsIDs componentsJoinedByString:@","];
    self.context[kQMCustomParameterDialogOccupantsIDs] = strIDs;
}

- (NSArray *)cParamDialogOccupantsIDs {
    
    NSString * strIDs = self.context[kQMCustomParameterDialogOccupantsIDs];
    
    NSArray *componets = [strIDs componentsSeparatedByString:@","];
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:componets.count];
    
    for (NSString *occupantID in componets) {
        [result addObject:@(occupantID.integerValue)];
    }
    
    return result;
}

#pragma mark - cParamNotificationType

- (void)setCParamNotificationType:(QMMessageNotificationType)cParamNotificationType {
    
    self.context[kQMCustomParameterNotificationType] = @(cParamNotificationType);
}

- (QMMessageNotificationType)cParamNotificationType {
    return (QMMessageNotificationType) [self.context[kQMCustomParameterNotificationType] integerValue];
}

#pragma mark - cParamMessageDeliveryStatus

- (void)setCParamMessageDeliveryStatus:(BOOL)cParamMessageDeliveryStatus {
    self.context[kQMCustomParameterChatMessageDeliveryStatus] = @(cParamMessageDeliveryStatus);
}

- (BOOL)cParamMessageDeliveryStatus {
    return [self.context[kQMCustomParameterChatMessageDeliveryStatus] boolValue];
}

#pragma mark - QBChatDialog

- (void)setCustomParametersWithChatDialog:(QBChatDialog *)chatDialog {
    
    self.cParamDialogID = chatDialog.ID;
    
    if (chatDialog.type == QBChatDialogTypeGroup) {
        self.cParamRoomJID = chatDialog.roomJID;
        self.cParamDialogRoomName = chatDialog.name;
    }
    self.cParamDialogOccupantsIDs = chatDialog.occupantIDs;
}

- (QBChatDialog *)chatDialogFromCustomParameters {

    QBChatDialog *chatDialog;
    if (self.cParamNotificationType == QMMessageNotificationTypeCreateGroupDialog) {
        chatDialog = [[QBChatDialog alloc] initWithDialogID:self.cParamDialogID type:QBChatDialogTypeGroup];
    } else if (self.cParamNotificationType == QMMessageNotificationTypeSendContactRequest) {
        chatDialog = [[QBChatDialog alloc] initWithDialogID:self.cParamDialogID type:QBChatDialogTypeGroup];
    }
    chatDialog.roomJID = self.cParamRoomJID;
    chatDialog.name = self.cParamDialogRoomName;
    chatDialog.occupantIDs = self.cParamDialogOccupantsIDs;
    
    return chatDialog;
}

@end
