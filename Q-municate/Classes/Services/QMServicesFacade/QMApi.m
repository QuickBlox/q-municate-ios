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

@property (strong, nonatomic) NSMutableArray *contactList;
@property (strong, nonatomic) NSMutableDictionary *users;
@property (strong, nonatomic) NSMutableArray *dialogs;
@property (strong, nonatomic) NSMutableDictionary *privateDialogs;
@property (strong, nonatomic) NSMutableDictionary *chatRooms;
@property (strong, nonatomic) NSMutableDictionary *messages;

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
        self.chatService = [[QMChatService alloc] init];
        self.messagesService = [[QMMessagesService alloc] init];
        /**
         TODO:temp
         */
        self.users = [NSMutableDictionary dictionary];
        self.contactList = [NSMutableArray array];
        
        self.dialogs = [NSMutableArray array];
        self.privateDialogs = [NSMutableDictionary dictionary];
        self.chatRooms = [NSMutableDictionary dictionary];
        
        self.messages = [NSMutableDictionary dictionary];

        [[QMChatReceiver instance] chatContactListDidChangeWithTarget:self block:^(QBContactList *contactList) {
            
            [self.contactList removeAllObjects];
            [self.contactList addObjectsFromArray:contactList.pendingApproval];
            [self.contactList addObjectsFromArray:contactList.contacts];
        }];
    }
    
    return self;
}

- (BOOL)checkResult:(Result *)result {
    
    if (!result.success) {
        [REAlertView showAlertWithMessage:result.errors.lastObject actionSuccess:NO];
    }
    
    return result.success;
}

@end
