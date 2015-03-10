//
//  QMServicesManager.h
//  Q-municate
//
//  Created by Andrey Ivanov on 24.11.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QMServices.h>
#import "QMProfile.h"

@class QMServicesManager;

#define QM [QMServicesManager instance]

QMServicesManager *qmServices(void);

@interface QMServicesManager : NSObject

+ (instancetype)instance;

@property (strong, nonatomic, readonly) QMAuthService *authService;
@property (strong, nonatomic, readonly) QMChatService *chatService;
@property (strong, nonatomic, readonly) QMContactListService *contactListService;
@property (strong, nonatomic, readonly) QMProfile *profile;

@end
