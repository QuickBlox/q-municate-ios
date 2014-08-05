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
#import "QMChatDialogsService.h"
#import "QMContentService.h"
#import "QMAVCallService.h"
#import "QMMessagesService.h"
#import "REAlertView+QMSuccess.h"
#import "QMChatReceiver.h"

const NSTimeInterval kQMPresenceTime = 30;

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
@property (strong, nonatomic) NSTimer *presenceTimer;

@end

@implementation QMApi

+ (instancetype)instance {
    
    static QMApi *servicesFacade = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        servicesFacade = [[self alloc] init];
        [QBChat instance].delegate = [QMChatReceiver instance];
        servicesFacade.presenceTimer = [NSTimer scheduledTimerWithTimeInterval:kQMPresenceTime
                                                                        target:servicesFacade
                                                                      selector:@selector(sendPresence)
                                                                      userInfo:nil
                                                                       repeats:YES];
    });
    
    return servicesFacade;
}

- (instancetype)init {
    
    self = [super init];
    if (self) {
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
    
    [self.authService start];
    [self.usersService start];
    [self.chatDialogsService start];
    [self.messagesService start];
    [self.avCallService start];
}

- (void)stopServices {
    
    [self.authService stop];
    [self.usersService stop];
    [self.chatDialogsService stop];
    [self.messagesService stop];
    [self.avCallService stop];
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

- (BOOL)loginChatWithUser:(QBUUser *)user completion:(QBChatResultBlock)block {
    
    if (([[QBChat instance] isLoggedIn])) {
        NSAssert(nil, @"Update this case");
    }
    
    [[QMChatReceiver instance] chatDidLoginWithTarget:self block:block];
    [[QMChatReceiver instance] chatDidNotLoginWithTarget:self block:block];
    
    return [[QBChat instance] loginWithUser:user];
}

- (BOOL)logoutChat {
    
    BOOL success = YES;
    [[QMChatReceiver instance] unsubscribeForTarget:self];
    if ([[QBChat instance] isLoggedIn]) {
        success = [[QBChat instance] logout];
    }
    return success;
}

#pragma mark - STATUS

- (void)sendPresence {
    
    if ([[QBChat instance] isLoggedIn]) {
        [[QBChat instance] sendPresence];
    }
}

- (void)applicationDidBecomeActive:(void(^)(BOOL success))completion {
    
    if (self.currentUser) {
        [[QBChat instance] loginWithUser:self.currentUser];
    }
}

- (void)applicationWillResignActive {
    
    [self logoutChat];
}

@end

@implementation NSObject(CurrentUser)

@dynamic currentUser;

- (QBUUser *)currentUser {
   return [[QMApi instance] currentUser];
}

@end
