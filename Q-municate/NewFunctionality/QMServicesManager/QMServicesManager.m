//
//  QMServicesManager.m
//  Q-municate
//
//  Created by Andrey on 24.11.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMServicesManager.h"

const NSTimeInterval kQMPresenceTimeInterval = 45;

QMServicesManager *qmServices(void) {
    
    QMServicesManager *serviceManager = [QMServicesManager instance];
    return serviceManager;
}

@interface QMServicesManager()

<QMServiceDataDelegate>

@property (strong, nonatomic) QMAuthService *authService;
@property (strong, nonatomic) QMProfile *profile;

@end

@implementation QMServicesManager

+ (instancetype)instance {
    
    static id servicesFacade = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        servicesFacade = [[self alloc] init];
        
        [QBChat instance].useMutualSubscriptionForContactList = YES;
        [QBChat instance].autoReconnectEnabled = YES;
        [QBChat instance].streamManagementEnabled = YES;
        
    });
    
    return servicesFacade;
}

- (instancetype)init {
    
    self = [super init];
    if (self) {
        self.profile = [QMProfile profile];
        self.authService = [[QMAuthService alloc] initWithServiceDataDelegate:self];
    }
    return self;
}

#pragma mark - QMServiceDataDelegate

- (QBUUser *)serviceDataCurrentProfile {
    
    return self.profile.userData;
}

@end

