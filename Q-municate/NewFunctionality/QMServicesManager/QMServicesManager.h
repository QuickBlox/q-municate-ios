//
//  QMServicesManager.h
//  Q-municate
//
//  Created by Andrey on 24.11.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QMServices.h>
#import "QMProfile.h"

@class QMServicesManager;

#define QM qmServices()

QMServicesManager *qmServices(void);

@interface QMServicesManager : NSObject

@property (strong, nonatomic, readonly) QMAuthService *authService;
@property (strong, nonatomic, readonly) QMProfile *profile;

+ (instancetype)instance;

@end
