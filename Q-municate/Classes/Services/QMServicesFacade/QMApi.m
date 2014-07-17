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

@interface QMApi()

@property (strong, nonatomic) NSMutableArray *dialogs;
@property (strong, nonatomic) NSMutableDictionary *privateDialogs;
@property (strong, nonatomic) NSMutableDictionary *chatRooms;

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
        [self.usersService start];
        
        self.settingsManager = [[QMSettingsManager alloc] init];
        self.facebookService = [[QMFacebookService alloc] init];
        self.avCallService = [[QMAVCallService alloc] init];
        self.chatDialogsService = [[QMChatDialogsService alloc] init];
        
        self.messagesService = [[QMMessagesService alloc] init];
        [self.messagesService start];
        /**
         TODO:temp
         */
        
        self.dialogs = [NSMutableArray array];
        self.privateDialogs = [NSMutableDictionary dictionary];
        self.chatRooms = [NSMutableDictionary dictionary];
    }
    
    return self;
}

- (void)cleanUp {
    
    [self.usersService destroy];
    [self.chatService destroy];
    
    [self.dialogs removeAllObjects];
    [self.privateDialogs removeAllObjects];
    [self.chatRooms removeAllObjects];
}

- (BOOL)checkResult:(Result *)result {
    
    if (!result.success) {
        [REAlertView showAlertWithMessage:result.errors.lastObject actionSuccess:NO];
    }
    
    return result.success;
}

@end
