//
//  QBChatAbstractMessage+QMCustomParameters.h
//  QMServices
//
//  Created by Andrey Ivanov on 24.07.14.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import "QBChatMessage+QMCustomParameters.h"
#import <objc/runtime.h>

#import "QBChatAttachment+QMCustomData.h"
#import "QBChatAttachment+QMFactory.h"

/**
 *  Message keys
 */
NSString const *kQMCustomParameterSaveToHistory = @"save_to_history";
NSString const *kQMCustomParameterMessageType = @"notification_type";
NSString const *kQMCustomParameterChatMessageID = @"chat_message_id";
NSString const *kQMCustomParameterMessageStatus = @"chat_message_status";

static NSString * const kQMChatAudioMessageTypeName = @"audio";
static NSString * const kQMChatVideoMessageTypeName = @"video";
static NSString * const kQMChatImageMessageTypeName = @"image";

static NSString * const kQMChatLocationMessageTypeName = @"location";
static NSString * const kQMLocationLatitudeKey = @"lat";
static NSString * const kQMLocationLongitudeKey = @"lng";

/**
 *  Dialog keys
 */
NSString const *kQMCustomParameterDialogID = @"dialog_id";
NSString const *kQMCustomParameterDialogRoomName = @"room_name";
NSString const *kQMCustomParameterDialogRoomPhoto = @"room_photo";
NSString const *kQMCustomParameterDialogRoomLastMessageDate = @"room_last_message_date";
NSString const *kQMCustomParameterDialogUpdatedDate = @"dialog_updated_date";
NSString const *kQMCustomParameterDialogType = @"type";
NSString const *kQMCustomParameterDialogRoomUpdatedDate = @"room_updated_date";

/**
 *  Public dialog keys
 */
NSString const *kQMCustomParameterDialogUpdateInfo = @"dialog_update_info";
NSString const *kQMCustomParameterDialogCurrentOccupantsIDs = @"current_occupant_ids";
NSString const *kQMCustomParameterDialogAddedOccupantsIDs = @"added_occupant_ids";
NSString const *kQMCustomParameterDialogDeletedOccupantsIDs = @"deleted_occupant_ids";

@interface QBChatMessage (Context)

@property (strong, nonatomic) NSMutableDictionary *context;
@property (strong, nonatomic) QBChatDialog *tDialog;

@end

@implementation QBChatMessage (QMCustomParameters)

/**
 *  Message params
 */
@dynamic saveToHistory;
@dynamic messageType;
@dynamic chatMessageID;
@dynamic messageDeliveryStatus;
@dynamic dialog;
@dynamic attachmentStatus;

/**
 *  Dialog params
 */
@dynamic dialogUpdateType;
@dynamic currentOccupantsIDs;
@dynamic addedOccupantsIDs;
@dynamic deletedOccupantsIDs;
@dynamic dialogName;
@dynamic dialogPhoto;

//MARK: - Context

- (NSMutableDictionary *)context {
    
    if (!self.customParameters) {
        self.customParameters = [NSMutableDictionary dictionary];
    }
    
    return self.customParameters;
}

//MARK: - Full QBChatDialog instance

- (QBChatDialog *)dialog {
    
    if (!self.tDialog) {
        
        if (self.context[kQMCustomParameterDialogID] == nil
            && [self.context[kQMCustomParameterDialogType] intValue] == 0) {
            // no chat dialog in this message
            return nil;
        }
        
        self.tDialog = [[QBChatDialog alloc]
                        initWithDialogID:self.context[kQMCustomParameterDialogID]
                        type:[self.context[kQMCustomParameterDialogType] intValue]];
        
        //Grap custom parameters;
        self.tDialog.name = self.context[kQMCustomParameterDialogRoomName];
        self.tDialog.photo = self.context[kQMCustomParameterDialogRoomPhoto];
        
        NSString *updatedAtTimeInterval = self.context[kQMCustomParameterDialogRoomUpdatedDate];
        
        if (updatedAtTimeInterval) {
            
            self.tDialog.updatedAt =
            [NSDate dateWithTimeIntervalSince1970:[updatedAtTimeInterval integerValue]];
        }
        
        NSString *lastMessageDateTimeInterval =
        self.context[kQMCustomParameterDialogRoomLastMessageDate];
        
        if (lastMessageDateTimeInterval) {
            self.tDialog.lastMessageDate =
            [NSDate dateWithTimeIntervalSince1970:[lastMessageDateTimeInterval integerValue]];
        }
        
        NSString * strIDs = self.context[kQMCustomParameterDialogCurrentOccupantsIDs];
        
        NSArray *componets = [strIDs componentsSeparatedByString:@","];
        NSMutableArray *occupatnsIDs = [NSMutableArray arrayWithCapacity:componets.count];
        
        for (NSString *occupantID in componets) {
            
            [occupatnsIDs addObject:@(occupantID.integerValue)];
        }
        
        self.tDialog.occupantIDs = occupatnsIDs;
    }
    
    return self.tDialog;
}

- (QBChatDialog *)tDialog {
    
    return objc_getAssociatedObject(self,
                                    @selector(tDialog));
}

- (void)setTDialog:(QBChatDialog *)tDialog {
    
    objc_setAssociatedObject(self, @selector(tDialog),
                             tDialog,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

//MARK: - Utils

- (void)updateCustomParametersWithDialog:(QBChatDialog *)dialog {
    
    self.tDialog = nil;
    
    self.context[kQMCustomParameterDialogID] = dialog.ID;
    self.context[kQMCustomParameterDialogType] = @(dialog.type);
    
    if (dialog.lastMessageDate != nil){
        NSNumber *lastMessageDate = @((NSUInteger)[dialog.lastMessageDate timeIntervalSince1970]);
        self.context[kQMCustomParameterDialogRoomLastMessageDate] = [lastMessageDate stringValue];
    }
    if (dialog.updatedAt != nil) {
        NSNumber *updatedAt = @((NSUInteger)[dialog.updatedAt timeIntervalSince1970]);
        self.context[kQMCustomParameterDialogRoomUpdatedDate] = [updatedAt stringValue];
    }
    
    if (dialog.type == QBChatDialogTypeGroup) {
        
        if (dialog.photo != nil) {
            
            self.context[kQMCustomParameterDialogRoomPhoto] = dialog.photo;
        }
        if (dialog.name != nil) {
            
            self.context[kQMCustomParameterDialogRoomName] = dialog.name;
        }
        
        NSString *strIDs = [dialog.occupantIDs componentsJoinedByString:@","];
        self.context[kQMCustomParameterDialogCurrentOccupantsIDs] = strIDs;
    }
}

- (NSArray *)arrayOfUserIDsWithString:(NSString *)userIDs {
    
    NSString *strIDs = userIDs;
    
    NSArray *componets = [strIDs componentsSeparatedByString:@","];
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:componets.count];
    
    for (NSString *occupantID in componets) {
        
        [result addObject:@(occupantID.integerValue)];
    }
    
    return result;
}

//MARK: - Message attachment status

- (QMMessageAttachmentStatus)attachmentStatus {
    
    return [[self tAttachmentStatus] integerValue];
}

- (void)setAttachmentStatus:(QMMessageAttachmentStatus)attachmentStatus {
    
    [self setTAttachmentStatus:@(attachmentStatus)];
}

- (NSNumber *)tAttachmentStatus {
    
    return objc_getAssociatedObject(self, @selector(tAttachmentStatus));
}

- (void)setTAttachmentStatus:(NSNumber *)attachmentStatusNumber {
    
    objc_setAssociatedObject(self,
                             @selector(tAttachmentStatus),
                             attachmentStatusNumber,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

//MARK: - Dialog occupants IDs

- (void)setCurrentOccupantsIDs:(NSArray *)currentOccupantsIDs {
    
    NSString *strIDs = [currentOccupantsIDs componentsJoinedByString:@","];
    self.context[kQMCustomParameterDialogCurrentOccupantsIDs] = strIDs;
}

- (NSArray *)currentOccupantsIDs {
    
    NSString *occupantsIDsString =
    self.context[kQMCustomParameterDialogCurrentOccupantsIDs];
    return [self arrayOfUserIDsWithString:occupantsIDsString];
}

- (void)setAddedOccupantsIDs:(NSArray *)addedOccupantsIDs {
    
    NSString *strIDs = [addedOccupantsIDs componentsJoinedByString:@","];
    self.context[kQMCustomParameterDialogAddedOccupantsIDs] = strIDs;
}

- (NSArray *)addedOccupantsIDs {
    
    NSString *occupantsIDsString =
    self.context[kQMCustomParameterDialogAddedOccupantsIDs];
    return [self arrayOfUserIDsWithString:occupantsIDsString];
}

- (void)setDeletedOccupantsIDs:(NSArray *)deletedOccupantsIDs {
    
    NSString *strIDs =
    [deletedOccupantsIDs componentsJoinedByString:@","];
    self.context[kQMCustomParameterDialogDeletedOccupantsIDs] = strIDs;
}

- (NSArray *)deletedOccupantsIDs {
    
    NSString *occupantsIDsString =
    self.context[kQMCustomParameterDialogDeletedOccupantsIDs];
    return [self arrayOfUserIDsWithString:occupantsIDsString];
}

//MARK: - Room updated at

- (void)setDialogUpdatedAt:(NSDate *)dialogUpdatedAt {
    
    NSNumber *updatedAt =
    @((NSUInteger)[dialogUpdatedAt timeIntervalSince1970]);
    self.context[kQMCustomParameterDialogRoomUpdatedDate] = [updatedAt stringValue];
}

- (NSDate *)dialogUpdatedAt {
    
    NSString *updatedAtTimeInterval =
    self.context[kQMCustomParameterDialogRoomUpdatedDate];
    return [NSDate dateWithTimeIntervalSince1970:[updatedAtTimeInterval doubleValue]];
}

//MARK: - Room name

- (void)setDialogName:(NSString *)dialogName {
    
    self.context[kQMCustomParameterDialogRoomName] = dialogName;
}

- (NSString *)dialogName {
    
    return self.context[kQMCustomParameterDialogRoomName];
}

//MARK: - Dialog photo

- (void)setDialogPhoto:(NSString *)dialogPhoto {
    
    self.context[kQMCustomParameterDialogRoomPhoto] = dialogPhoto;
}

- (NSString *)dialogPhoto {
    
    return self.context[kQMCustomParameterDialogRoomPhoto];
}

//MARK:- cParamChatMessageID

- (void)setChatMessageID:(NSString *)chatMessageID {
    
    self.context[kQMCustomParameterChatMessageID] = chatMessageID;
}

- (NSString *)chatMessageID {
    
    return self.context[kQMCustomParameterChatMessageID];
}

//MARK: - cParamSaveToHistory

- (void)setSaveToHistory:(NSString *)saveToHistory {
    
    self.context[kQMCustomParameterSaveToHistory] = saveToHistory;
}

- (NSString *)saveToHistory {
    
    return self.context[kQMCustomParameterSaveToHistory];
}

//MARK: - messageType

- (void)setMessageType:(QMMessageType)messageType {
    
    if (messageType != QMMessageTypeText) {
        
        self.context[kQMCustomParameterMessageType] = @(messageType);
    }
}

- (QMMessageType)messageType {
    
    return [self.context[kQMCustomParameterMessageType] integerValue];
}

//MARK: - dialogUpdateType

- (void)setDialogUpdateType:(QMDialogUpdateType)dialogUpdateType {
    
    self.context[kQMCustomParameterDialogUpdateInfo] = @(dialogUpdateType);
}

- (QMDialogUpdateType)dialogUpdateType {
    
    return [self.context[kQMCustomParameterDialogUpdateInfo] integerValue];
}

//MARK: - extra params

- (BOOL)isNotificationMessage {
    
    return self.messageType != QMMessageTypeText;
}

- (BOOL)isMediaMessage {
    
    return self.attachments.count > 0;
}

//MARK: - Location

- (CLLocationCoordinate2D)locationCoordinate {
    
    QBChatAttachment *locationAttachment = [self _locationAttachment];
    
    if (locationAttachment == nil) {
        
        return kCLLocationCoordinate2DInvalid;
    }
    
    CLLocationDegrees lat =
    [locationAttachment.context[kQMLocationLatitudeKey] doubleValue];
    CLLocationDegrees lng =
    [locationAttachment.context[kQMLocationLongitudeKey] doubleValue];
    
    return CLLocationCoordinate2DMake(lat, lng);
}

- (void)setLocationCoordinate:(CLLocationCoordinate2D)locationCoordinate {
    
    QBChatAttachment *locationAttachment = [QBChatAttachment locationAttachmentWithCoordinate:locationCoordinate];
    self.attachments = @[locationAttachment];
}

- (BOOL)isLocationMessage {
    
    __block BOOL isLocationMessage = NO;
    
    [self.attachments enumerateObjectsUsingBlock:^(QBChatAttachment * _Nonnull obj,
                                                   NSUInteger __unused idx,
                                                   BOOL * _Nonnull stop) {
        
        if ([obj.type isEqualToString:kQMChatLocationMessageTypeName]) {
            
            isLocationMessage = YES;
            *stop = YES;
        }
    }];
    
    return isLocationMessage;
}

- (QBChatAttachment *)_locationAttachment {
    
    __block QBChatAttachment *locationAttachment = nil;
    
    [self.attachments enumerateObjectsUsingBlock:^(QBChatAttachment * _Nonnull obj,
                                                   NSUInteger __unused idx,
                                                   BOOL * _Nonnull stop) {
        
        if ([obj.type isEqualToString:kQMChatLocationMessageTypeName]) {
            
            locationAttachment = obj;
            *stop = YES;
        }
    }];
    
    return locationAttachment;
}

#pragma mark - Media

- (BOOL)isVideoAttachment {
    
    __block BOOL isVideoAttachment = NO;
    
    [self.attachments enumerateObjectsUsingBlock:^(QBChatAttachment * _Nonnull obj, NSUInteger __unused idx, BOOL * _Nonnull stop) {
        
        if ([obj.type isEqualToString:kQMChatVideoMessageTypeName]) {
            isVideoAttachment = YES;
            *stop = YES;
        }
    }];
    
    return isVideoAttachment;
}

- (BOOL)isAudioAttachment {
    
    __block BOOL isAudioAttachment = NO;
    
    [self.attachments enumerateObjectsUsingBlock:^(QBChatAttachment * _Nonnull obj, NSUInteger __unused idx, BOOL * _Nonnull stop) {
        
        if ([obj.type isEqualToString:kQMChatAudioMessageTypeName]) {
            isAudioAttachment = YES;
            *stop = YES;
        }
    }];
    
    return isAudioAttachment;
}

- (BOOL)isImageAttachment {
    
    __block BOOL isImageAttachment = NO;
    
    [self.attachments enumerateObjectsUsingBlock:^(QBChatAttachment * _Nonnull obj, NSUInteger __unused idx, BOOL * _Nonnull stop) {
        
        if ([obj.type isEqualToString:kQMChatImageMessageTypeName]) {
            isImageAttachment = YES;
            *stop = YES;
        }
    }];
    
    return isImageAttachment;
}

@end
