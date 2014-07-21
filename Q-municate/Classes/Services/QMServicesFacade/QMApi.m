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
#import "QMChatReceiver.h"


@implementation QMApi

+ (instancetype)instance {
    
    static id servicesFacade = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        servicesFacade = [[self alloc] init];
    });
    
    return servicesFacade;
}

- (void)dealloc {
    NSLog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
}

- (instancetype)init {
    
    self = [super init];
    if (self) {
        
        self.chatService = [[QMChatService alloc] init];
        self.authService = [[QMAuthService alloc] init];
        self.usersService = [[QMUsersService alloc] init];
        self.chatDialogsService = [[QMChatDialogsService alloc] init];
        self.messagesService = [[QMMessagesService alloc] init];
        self.settingsManager = [[QMSettingsManager alloc] init];
        self.facebookService = [[QMFacebookService alloc] init];
        self.avCallService = [[QMAVCallService alloc] init];
        
        [self.usersService start];
        [self.chatDialogsService start];
        [self.messagesService start];
    }
    
    return self;
}

- (void)cleanUp {
    
    [self.usersService destroy];
    [self.chatService destroy];
    [self.chatDialogsService destroy];
}

- (void)fetchAllHistory {

    /**
     Feach Dialogs
     */
    __weak __typeof(self)weakSelf = self;
    [self fetchAllDialogs:^{
        
        NSArray *allOccupantIDs = [weakSelf allOccupantIDsFromDialogsHistory];
        
        [weakSelf retrieveUsersWithIDs:allOccupantIDs completion:^(BOOL updated) {
            NSLog(@"");
        }];
        
    }];
    
}

- (BOOL)checkResult:(Result *)result {
    
    if (!result.success) {
        [REAlertView showAlertWithMessage:result.errors.lastObject actionSuccess:NO];
    }
    
    return result.success;
}

@end
