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
#import "QMPopoversFactory.h"
#import "QMMainTabBarController.h"

const NSTimeInterval kQMPresenceTime = 30;

@interface QMApi()

@property (strong, nonatomic) QMAuthService *authService;
@property (strong, nonatomic) QMSettingsManager *settingsManager;
@property (strong, nonatomic) QMUsersService *usersService;
@property (strong, nonatomic) QMAVCallService *avCallService;
@property (strong, nonatomic) QMChatDialogsService *chatDialogsService;
@property (strong, nonatomic) QMMessagesService *messagesService;
@property (strong, nonatomic) QMChatReceiver *responceService;
@property (strong, nonatomic) QMContentService *contentService;
@property (strong, nonatomic) NSTimer *presenceTimer;

@property (nonatomic) dispatch_group_t group;

@end

@implementation QMApi

@dynamic currentUser;

+ (instancetype)instance {
    
    static QMApi *servicesFacade = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        servicesFacade = [[self alloc] init];
        [QBChat instance].useMutualSubscriptionForContactList = YES;
//        [QBChat instance].autoReconnectEnabled = YES;
        [QBChat instance].streamManagementEnabled = YES;
        
        [[QBChat instance] addDelegate:[QMChatReceiver instance]];
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
        self.messagesService = [[QMMessagesService alloc] init];
        self.authService = [[QMAuthService alloc] init];
        self.usersService = [[QMUsersService alloc] init];
        self.chatDialogsService = [[QMChatDialogsService alloc] init];
        self.settingsManager = [[QMSettingsManager alloc] init];
        self.avCallService = [[QMAVCallService alloc] init];
        self.contentService = [[QMContentService alloc] init];
        
        __weak typeof(self)weakSelf = self;
        
        [[QMChatReceiver instance] chatDidReceiveMessageWithTarget:self block:^(QBChatMessage *message) {
            [weakSelf.chatDialogsService updateOrCreateDialogWithMessage:message isMine:(message.senderID == weakSelf.currentUser.ID)];
        }];
        
        [[QMChatReceiver instance] chatRoomDidReceiveMessageWithTarget:self block:^(QBChatMessage *message, NSString *roomJID) {

            // check for chat dialog:
            [weakSelf.chatDialogsService updateOrCreateDialogWithMessage:message isMine:(message.senderID == weakSelf.currentUser.ID)];
            
            if (message.cParamNotificationType == QMMessageNotificationTypeCreateGroupDialog) {
                [weakSelf retriveUsersForNotificationIfNeeded:message];
            } else if (message.cParamNotificationType == QMMessageNotificationTypeUpdateGroupDialog) {
                if (message.cParamDialogOccupantsIDs) {
                    [weakSelf retriveUsersForNotificationIfNeeded:message];
                    return;
                }
                [weakSelf.messagesService addMessageToHistory:message withDialogID:message.cParamDialogID];
            }
        }];
        
        [[QMChatReceiver instance] chatRoomDidEnterWithTarget:self block:^(QBChatRoom *room) {
            [weakSelf fireEnqueuedMessageForChatRoomWithJID:room.JID];
        }];
    }
    
    return self;
}

- (void)setCurrentUser:(QBUUser *)currentUser {
    self.messagesService.currentUser = currentUser;
    if (!currentUser) {
        [self.usersService deleteUser:currentUser];
    } else {
        [self.usersService addUser:currentUser];
    }
}

- (QBUUser *)currentUser {
    return self.messagesService.currentUser;
}

- (void)startServices {
    
    [self.authService start];
    [self.messagesService start];
    [self.usersService start];
    [self.chatDialogsService start];
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
        
        [weakSelf.usersService retrieveUsersWithIDs:allOccupantIDs completion:^(BOOL updated) {
            completion();
        }];
    }];
}

- (void)retriveUsersForNotificationIfNeeded:(QBChatMessage *)notification
{
    __weak typeof(self)weakSelf = self;
    [self retriveIfNeededUsersWithIDs:notification.cParamDialogOccupantsIDs completion:^(BOOL retrieveWasNeeded) {
        [weakSelf.messagesService addMessageToHistory:notification withDialogID:notification.cParamDialogID];
        [[QMChatReceiver instance] message:notification addedToGroupUsersWasLoaded:retrieveWasNeeded];
    }];
}

- (BOOL)checkResult:(Result *)result {
    
    if (!result.success) {
        [REAlertView showAlertWithMessage:result.errors.lastObject actionSuccess:NO];
    }
    
    return result.success;
}

#pragma mark - STATUS

- (void)sendPresence {
    
    if ([[QBChat instance] isLoggedIn]) {
        [[QBChat instance] sendPresence];
    }
}

- (void)applicationDidBecomeActive:(void(^)(BOOL success))completion {
    _group = dispatch_group_create();
    dispatch_group_enter(_group);
    
    [self fetchDialogsWithLastActivityFromDate:self.settingsManager.lastActivityDate completion:^(QBDialogsPagedResult *result) {
        dispatch_group_leave(_group);
    }];
    
    dispatch_group_enter(_group);
    [self loginChat:^(BOOL success) {
        dispatch_group_leave(_group);
    }];
    
    dispatch_group_notify(_group, dispatch_get_main_queue(), ^{
        
        if ([QBChat instance].isLoggedIn) {
            [self.chatDialogsService joinRooms];
            [[QMChatReceiver instance] postDialogsHistoryUpdated];
            
            [self fetchMessagesForActiveChatIfNeededWithCompletion:^(BOOL fetchWasNeeded) {
                if (completion) completion(YES);
            }];
        }
    });
}

- (void)applicationWillResignActive {
    [self logoutFromChat];
}

- (void)openChatPageForPushNotification:(NSDictionary *)notification
{
    NSString *dialogID = notification[@"dialog_id"];
    QBChatDialog *dialog = [self chatDialogWithID:dialogID];
    if (dialog == nil) {
        return;
    }
    
    QMChatViewController *chatController = [QMPopoversFactory chatControllerWithDialogID:dialogID];
    UIWindow *window = [[UIApplication sharedApplication].windows firstObject];
    QMMainTabBarController *tabBar = (QMMainTabBarController *)window.rootViewController;
    UINavigationController *navigationController = (UINavigationController *)[tabBar selectedViewController];
    [navigationController pushViewController:chatController animated:YES];
}

@end

@implementation NSObject(CurrentUser)

@dynamic currentUser;

- (QBUUser *)currentUser {
   return [[QMApi instance] currentUser];
}

@end
