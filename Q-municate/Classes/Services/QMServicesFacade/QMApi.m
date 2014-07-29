//
//  QMServicesFacade.m
//  Qmunicate
//
//  Created by Andrey Ivanov on 01.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMApi.h"

#import "QMSettingsManager.h"
#import "QMFacebookService.h"
#import "QMAuthService.h"
#import "QMUsersService.h"
#import "QMChatService.h"
#import "QMChatDialogsService.h"
#import "QMContentService.h"
#import "QMAVCallService.h"
#import "QMMessagesService.h"
#import "REAlertView+QMSuccess.h"
#import "QMChatReceiver.h"

@interface QMApi()

@property (strong, nonatomic) QMAuthService *authService;
@property (strong, nonatomic) QMSettingsManager *settingsManager;
@property (strong, nonatomic) QMFacebookService *facebookService;
@property (strong, nonatomic) QMUsersService *usersService;
@property (strong, nonatomic) QMChatService *chatService;
@property (strong, nonatomic) QMAVCallService *avCallService;
@property (strong, nonatomic) QMChatDialogsService *chatDialogsService;
@property (strong, nonatomic) QMMessagesService *messagesService;
@property (strong, nonatomic) QMChatReceiver *responceService;
@property (strong, nonatomic) QMContentService *contentService;

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
        self.contentService = [[QMContentService alloc] init];
    }
    
    return self;
}

- (void)startServices {
    
    [self.chatService start];
    [self.usersService start];
    [self.chatDialogsService start];
    [self.messagesService start];
    [self.avCallService start];
}

- (void)stopServices {
    
    [self.chatService destroy];
    [self.usersService destroy];
    [self.chatDialogsService destroy];
    [self.messagesService destroy];
    [self.avCallService destroy];
}

- (void)fetchAllHistory:(void(^)(void))completion {
    /**
     Feach Dialogs
     */
    __weak __typeof(self)weakSelf = self;
    [self fetchAllDialogs:^{
        
        NSArray *allOccupantIDs = [weakSelf allOccupantIDsFromDialogsHistory];
        
        [weakSelf retrieveUsersWithIDs:allOccupantIDs completion:^(BOOL updated) {
            completion();
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
