//
//  QMServicesFacade.m
//  Qmunicate
//
//  Created by Andrey on 01.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMApi.h"

#import "QMSettingsManager.h"
#import "QMFacebookService.h"
#import "QMAuthService.h"
#import "QMUsersService.h"
#import "QMChatService.h"
#import "QMContent.h"
#import "QMChatDialogsService.h"
#import "QMAVCallService.h"
#import "QMMessagesService.h"

#import "REAlertView+QMSuccess.h"

@interface QMApi()

@end

@implementation QMApi

+ (instancetype)instance {
    
    static id servicesFacade = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        servicesFacade = [[self alloc] init];
    });
    
    return servicesFacade;
}

- (instancetype)init {
    
    self = [super init];
    if (self) {
        
        self.authService = [[QMAuthService alloc] init];
        self.settingsManager = [[QMSettingsManager alloc] init];
        self.facebookService = [[QMFacebookService alloc] init];
        self.usersService = [[QMUsersService alloc] init];
        self.avCallService = [[QMAVCallService alloc] init];
        self.chatDialogsService = [[QMChatDialogsService alloc] init];
        self.messagesService = [[QMMessagesService alloc] init];
        self.chatService = [[QMChatService alloc] init];
    }
    
    return self;
}

- (BOOL)checkResult:(Result *)result {
    
    if (result.success) {
        return YES;
    }
    else {
        [REAlertView showAlertWithMessage:result.errors.lastObject actionSuccess:NO];
        return NO;
    }
}

@end
