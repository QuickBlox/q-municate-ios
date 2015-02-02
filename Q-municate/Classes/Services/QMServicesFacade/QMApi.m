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
#import <Reachability.h>
#import "QMPopoversFactory.h"
#import "QMSettingsManager.h"
#import "QMMainTabBarController.h"

#import <SVProgressHUD.h>

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
@property (strong, nonatomic) Reachability *internetConnection;
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
        [QBChat instance].autoReconnectEnabled = YES;
//        [QBChat instance].streamManagementEnabled = YES;
        
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
        self.internetConnection = [Reachability reachabilityForInternetConnection];
    
        __weak typeof(self)weakSelf = self;
        
        void (^internetConnectionBlock)(Reachability *reachability) = ^(Reachability *reachability) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[QMChatReceiver instance] internetConnectionIsActive:reachability.isReachable];
            });
        };
        
        self.internetConnection.reachableBlock = internetConnectionBlock;
        self.internetConnection.unreachableBlock = internetConnectionBlock;
        
        [[QMChatReceiver instance] chatDidFailWithTarget:self block:^(NSError *error) {
            // some
            [REAlertView showAlertWithMessage:NSLocalizedString(@"QM_STR_CHECK_INTERNET_CONNECTION", nil) actionSuccess:NO];
        }];
        
        
        // XMPP Chat messaging handling
        
        void (^updateHistory)(QBChatMessage *) = ^(QBChatMessage *message) {
            
            if (message.cParamNotificationType == QMMessageNotificationTypeSendContactRequest) {
                return;
            }
            if (message.recipientID != message.senderID) {
                if (message.cParamNotificationType == QMMessageNotificationTypeCreateGroupDialog && !message.cParamSaveToHistory) {
                    return;
                }
                [weakSelf.messagesService addMessageToHistory:message withDialogID:message.cParamDialogID];
            }
        };
        
        [[QMChatReceiver instance] chatDidReceiveMessageWithTarget:self block:^(QBChatMessage *message) {
            // message service update:
            updateHistory(message);
            
            // dialogs service update:
            [weakSelf.chatDialogsService updateOrCreateDialogWithMessage:message isMine:(message.senderID == weakSelf.currentUser.ID)];
            
            // fire chatAfterDidReceiveMessage for other cases:
            if (message.cParamNotificationType == QMMessageNotificationTypeSendContactRequest) {
                [weakSelf retriveUsersForNotificationIfNeeded:message];
            }
            
            // users
            if (message.cParamNotificationType == QMMessageNotificationTypeDeleteContactRequest) {
                BOOL contactWasDeleted = [weakSelf.usersService deleteContactRequestUserID:message.senderID];
                if (contactWasDeleted) {
                    [[QMChatReceiver instance] contactRequestUsersListChanged];
                }
            }
        }];
        
        [[QMChatReceiver instance] chatRoomDidReceiveMessageWithTarget:self block:^(QBChatMessage *message, NSString *roomJID) {

            
            if (message.cParamNotificationType == QMMessageNotificationTypeCreateGroupDialog) {
                void (^DeliveryBlock)(NSError *error) = weakSelf.messagesService.messageDeliveryBlockList[roomJID];
                if (DeliveryBlock) {
                    [weakSelf.messagesService.messageDeliveryBlockList removeObjectForKey:roomJID];
                    DeliveryBlock(nil);
                }
            }
            updateHistory(message);
            
            // check for chat dialog:
            [weakSelf.chatDialogsService updateOrCreateDialogWithMessage:message isMine:(message.senderID == weakSelf.currentUser.ID)];
            
            // check users if needed:
            if (message.cParamNotificationType == QMMessageNotificationTypeCreateGroupDialog) {
                [weakSelf retriveUsersForNotificationIfNeeded:message];
            } else if (message.cParamNotificationType == QMMessageNotificationTypeUpdateGroupDialog) {
                if (message.cParamDialogOccupantsIDs.count > 0) {
                    [weakSelf retriveUsersForNotificationIfNeeded:message];
                    return;
                }
                [weakSelf.messagesService addMessageToHistory:message withDialogID:message.cParamDialogID];
                [[QMChatReceiver instance] chatAfterDidReceiveMessage:message];
            }
        }];
    }
    
    [self.internetConnection startNotifier];
    
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
    NSArray *idsToFetch = nil;
    if (notification.cParamNotificationType == QMMessageNotificationTypeSendContactRequest) {
        idsToFetch = @[@(notification.senderID)];
    } else {
        idsToFetch = notification.cParamDialogOccupantsIDs;
    }
    [self retriveIfNeededUsersWithIDs:idsToFetch completion:^(BOOL retrieveWasNeeded) {
        [weakSelf.messagesService addMessageToHistory:notification withDialogID:notification.cParamDialogID];
        [[QMChatReceiver instance] chatAfterDidReceiveMessage:notification];
    }];
}

- (BOOL)checkResult:(Result *)result {
    
    if (!result.success) {
        [REAlertView showAlertWithMessage:result.errors.lastObject actionSuccess:NO];
    }
    
    return result.success;
}

- (BOOL)isInternetConnected
{
    return self.internetConnection.isReachable;
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

- (void)openChatPageForPushNotification:(NSDictionary *)notification completion:(void(^)(BOOL completed))completionBlock
{
    if ([QBChat instance].isLoggedIn) {
        if (completionBlock) completionBlock(NO);
        return;
    }
    
    NSString *dialogID = notification[@"dialog_id"];
    QBChatDialog *dialog = [self chatDialogWithID:dialogID];
    __weak typeof(self)weakSelf = self;
    if (dialog == nil) {
        [self fetchChatDialogWithID:dialogID completion:^(QBChatDialog *chatDialog) {

            [weakSelf openChatPageForPushNotification:notification completion:completionBlock];
        }];
        return;
    }
    [self openChatControllerForDialogWithID:dialogID];
    if (completionBlock) completionBlock(YES);
}

- (void)openChatControllerForDialogWithID:(NSString *)dialogID
{
    NSString *dialogWithIDWasEntered = [QMApi instance].settingsManager.dialogWithIDisActive;
    if ([dialogWithIDWasEntered isEqualToString:dialogID]) {
        return;
    }
    UIViewController *chatController = [QMPopoversFactory chatControllerWithDialogID:dialogID];
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
