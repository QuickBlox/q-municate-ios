//
//  QBChatAbstractMessage+CustomParameters.h
//  Qmunicate
//
//  Created by Andrey Ivanov on 24.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <Quickblox/Quickblox.h>

extern NSString const* kQMCustomParameterSaveToHistory;
extern NSString const* kQMCustomParameterDialogID;
extern NSString const* kQMCustomParameterDateSent;
extern NSString const *kQMCustomParameterChatMessageID;

@interface QBChatAbstractMessage (CustomParameters)

@property (strong, nonatomic) NSString *cParamSaveToHistory;
@property (strong, nonatomic) NSNumber *cParamNotificationType;
@property (strong, nonatomic) NSString *cParamChatMessageID;
@property (strong, nonatomic) NSNumber *cParamDateSent;

@property (strong, nonatomic) NSString *cParamDialogID;
@property (strong, nonatomic) NSString *cParamRoomJID;
@property (strong, nonatomic) NSString *cParamDialogName;
@property (strong, nonatomic) NSNumber *cParamDialogType;
@property (strong, nonatomic) NSString *cParamDialogOccupantsIDs;

- (void)setCustomParametersWithChatDialog:(QBChatDialog *)chatDialog;

@end
