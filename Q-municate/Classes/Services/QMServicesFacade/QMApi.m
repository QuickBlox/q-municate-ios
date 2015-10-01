//
//  QMApi.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 9/24/15.
//  Copyright © 2015 Quickblox. All rights reserved.
//

#import "QMApi.h"

#import "QMSettingsManager.h"
#import "QMAVCallManager.h"
#import "QMContentService.h"
#import <Reachability.h>
#import "REAlertView+QMSuccess.h"
#import "QMPopoversFactory.h"
#import "QMMainTabBarController.h"

#import "QMMessageBarStyleSheetFactory.h"
#import "QMSoundManager.h"

#import <_CDMessage.h>
#import <_CDDialog.h>

const NSTimeInterval kQMPresenceTime = 30;

@interface QMApi()

@property (strong, nonatomic) QMSettingsManager *settingsManager;
@property (strong, nonatomic) QMContactListService* contactListService;
@property (strong, nonatomic) QMAVCallManager *avCallManager;
@property (strong, nonatomic) QMContentService *contentService;
@property (strong, nonatomic) Reachability *internetConnection;
@property (strong, nonatomic) NSTimer *presenceTimer;

@property (nonatomic) dispatch_group_t group; // ???

/**
 *  Logout group for synchronous completion.
 */
@property (nonatomic, strong) dispatch_group_t logoutGroup;

@end

@implementation QMApi

@dynamic currentUser;

+ (instancetype)instance {
    
    static QMApi *servicesFacade = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        servicesFacade = [[self alloc] init];
        //[QBChat instance].useMutualSubscriptionForContactList = YES;
        [QBChat instance].autoReconnectEnabled = YES;

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
        
#if QM_AUDIO_VIDEO_ENABLED == 1
        _avCallManager = [[QMAVCallManager alloc] initWithServiceManager:self];
#endif
        _authService = [[QMAuthService alloc] initWithServiceManager:self];
        [QMChatCache setupDBWithStoreNamed:kChatCacheNameKey];
        [QMChatCache instance].messagesLimitPerDialog = 10;
        _chatService = [[QMChatService alloc] initWithServiceManager:self cacheDataSource:self];
        [QMContactListCache setupDBWithStoreNamed:kContactListCacheNameKey];
        _contactListService = [[QMContactListService alloc] initWithServiceManager:self cacheDataSource:self];
        _settingsManager = [[QMSettingsManager alloc] init];
        _contentService = [[QMContentService alloc] init];
        _internetConnection = [Reachability reachabilityForInternetConnection];
        [_chatService addDelegate:self];
        _logoutGroup = dispatch_group_create();
    }
    
    [self.internetConnection startNotifier];
    return self;
}

- (QBUUser *)currentUser {
    return [QBSession currentSession].currentUser;
}

- (void)fetchAllHistory:(void(^)(void))completion {
    /**
     Feach Dialogs
     */
    __weak __typeof(self)weakSelf = self;
    [self fetchAllDialogs:^{
        
        NSArray *allOccupantIDs = [weakSelf allOccupantIDsFromDialogsHistory];
        
        [weakSelf.contactListService retrieveUsersWithIDs:allOccupantIDs forceDownload:NO completion:^(QBResponse *response, QBGeneralResponsePage *page, NSArray *users) {
            //
            completion();
        }];
    }];
}

- (void)retriveUsersForNotificationIfNeeded:(QBChatMessage *)notification
{
    NSArray *idsToFetch = nil;
    if (notification.messageType == QMMessageTypeContactRequest) {
        idsToFetch = @[@(notification.senderID)];
    } else {
        idsToFetch = notification.dialog.occupantIDs;
    }
    [self retriveIfNeededUsersWithIDs:idsToFetch completion:^(BOOL retrieveWasNeeded) {

    }];
}

- (BOOL)isInternetConnected {
    
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
    
    [self fetchDialogsWithLastActivityFromDate:self.settingsManager.lastActivityDate completion:^(QBResponse *response, NSArray *dialogObjects, NSSet *dialogsUsersIDs, QBResponsePage *page) {
        //
        dispatch_group_leave(_group);
    }];
    
    dispatch_group_enter(_group);
    [self loginChat:^(BOOL success) {
        dispatch_group_leave(_group);
    }];
    
    dispatch_group_notify(_group, dispatch_get_main_queue(), ^{
        
        if ([QBChat instance].isLoggedIn) {
            [self joinGroupDialogs];
            
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
        
        if (completionBlock)
            completionBlock(NO);
        
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
        
    }else {
        
        [self openChatControllerForDialogWithID:dialogID];
        if (completionBlock) completionBlock(YES);
    }
    
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

#pragma mark QMContactListServiceCacheDelegate delegate

- (void)cachedUsers:(QMCacheCollection)block {
    [QMContactListCache.instance usersSortedBy:@"id" ascending:YES completion:block];
}

- (void)cachedContactListItems:(QMCacheCollection)block {
    [QMContactListCache.instance contactListItems:block];
}

#pragma mark QMContactListServiceDelegate protocol



#pragma mark QMServicesManagerProtocol

- (BOOL)isAuthorized {
    return self.authService.isAuthorized;
}

- (void)handleErrorResponse:(QBResponse *)response {
    
    if (![self isAuthorized]) return;
    NSString *errorMessage = [[response.error description] stringByReplacingOccurrencesOfString:@"(" withString:@""];
    errorMessage = [errorMessage stringByReplacingOccurrencesOfString:@")" withString:@""];

    switch (response.status) {
        case QBResponseStatusCodeServerError:
            errorMessage = @"Bad Gateway, please try again";
            break;
        case QBResponseStatusCodeUnknown:
            errorMessage = @"Connection network error, please try again";
            break;
        case QBResponseStatusCodeUnAuthorized:
            errorMessage = @"Incorrect Username or Password";
            break;
        case QBResponseStatusCodeValidationFailed:
            errorMessage = @"Incorrect Username or Password";
            break;
        default:
            errorMessage = @"Error. Please check your internet connection";
            break;
    }

    [REAlertView showAlertWithMessage:errorMessage actionSuccess:NO];
}

#pragma mark QMChatServiceCache delegate

- (void)chatService:(QMChatService *)chatService didAddChatDialogToMemoryStorage:(QBChatDialog *)chatDialog {
    [QMChatCache.instance insertOrUpdateDialog:chatDialog completion:nil];
}

- (void)chatService:(QMChatService *)chatService didAddChatDialogsToMemoryStorage:(NSArray *)chatDialogs {
    [QMChatCache.instance insertOrUpdateDialogs:chatDialogs completion:nil];
}

- (void)chatService:(QMChatService *)chatService didUpdateChatDialogInMemoryStorage:(QBChatDialog *)chatDialog {
    [QMChatCache.instance insertOrUpdateDialog:chatDialog completion:nil];
}

- (void)chatService:(QMChatService *)chatService didAddMessageToMemoryStorage:(QBChatMessage *)message forDialogID:(NSString *)dialogID {
    [QMChatCache.instance insertOrUpdateMessage:message withDialogId:dialogID completion:nil];
}

- (void)chatService:(QMChatService *)chatService didAddMessagesToMemoryStorage:(NSArray *)messages forDialogID:(NSString *)dialogID {
    [QMChatCache.instance insertOrUpdateMessages:messages withDialogId:dialogID completion:nil];
}

- (void)chatService:(QMChatService *)chatService didUpdateMessage:(QBChatMessage *)message forDialogID:(NSString *)dialogID {
    [QMChatCache.instance insertOrUpdateMessage:message withDialogId:dialogID completion:nil];
}

- (void)chatService:(QMChatService *)chatService didDeleteChatDialogWithIDFromMemoryStorage:(NSString *)chatDialogID {
    [QMChatCache.instance deleteDialogWithID:chatDialogID completion:nil];
}

- (void)chatService:(QMChatService *)chatService didReceiveNotificationMessage:(QBChatMessage *)message createDialog:(QBChatDialog *)dialog {
    NSAssert(message.dialogID == dialog.ID, @"must be equal");
    
    [QMChatCache.instance insertOrUpdateMessage:message withDialogId:dialog.ID completion:nil];
    [QMChatCache.instance insertOrUpdateDialog:dialog completion:nil];
}

#pragma mark QMChatServiceCacheDataSource

- (void)cachedDialogs:(QMCacheCollection)block {
    [QMChatCache.instance dialogsSortedBy:CDDialogAttributes.lastMessageDate ascending:YES completion:^(NSArray *dialogs) {
        block(dialogs);
    }];
}

- (void)cachedDialogWithID:(NSString *)dialogID completion:(void (^)(QBChatDialog *dialog))completion {
    [QMChatCache.instance dialogByID:dialogID completion:^(QBChatDialog *cachedDialog) {
        completion(cachedDialog);
    }];
}

- (void)cachedMessagesWithDialogID:(NSString *)dialogID block:(QMCacheCollection)block {
    [QMChatCache.instance messagesWithDialogId:dialogID sortedBy:CDMessageAttributes.messageID ascending:YES completion:^(NSArray *array) {
        block(array);
    }];
}

@end

@implementation NSObject(CurrentUser)

@dynamic currentUser;

- (QBUUser *)currentUser {
    return [[QMApi instance] currentUser];
}

@end
