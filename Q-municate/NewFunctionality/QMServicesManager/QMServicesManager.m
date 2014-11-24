//
//  QMServicesManager.m
//  Q-municate
//
//  Created by Andrey Ivanov on 24.11.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMServicesManager.h"

const NSTimeInterval kQMPresenceTimeInterval = 45;
NSString *const kQMChatCacheStoreName = @"QMCahtCacheStorage";
NSString *const kQMContactListCacheStoreName = @"QMContactListStorage";

QMServicesManager *qmServices(void) {
    
    static QMServicesManager *_sharedQMServicesManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedQMServicesManager = [[QMServicesManager alloc] init];
        
        [QBConnection setAutoCreateSessionEnabled:YES];
        [QBChat instance].useMutualSubscriptionForContactList = YES;
        [QBChat instance].autoReconnectEnabled = YES;
        [QBChat instance].streamManagementEnabled = YES;
        
    });
    
    return _sharedQMServicesManager;
}

@interface QMServicesManager()

<QMServiceDataDelegate, QMChatServiceDelegate, QMContactsServiceDelegate>

@property (strong, nonatomic) QMAuthService *authService;
@property (strong, nonatomic) QMChatService *chatService;
@property (strong, nonatomic) QMContactListService *contactListService;
@property (strong, nonatomic) QMProfile *profile;

@end

@implementation QMServicesManager

- (instancetype)init {
    
    self = [super init];
   
    if (self) {
        
        self.profile = [QMProfile profile];
        self.authService = [[QMAuthService alloc] initWithServiceDataDelegate:self];
        self.chatService = [[QMChatService alloc] initWithServiceDataDelegate:self];
        self.contactListService = [[QMContactListService alloc] initWithServiceDataDelegate:self];
        
        [self.chatService addDelegate:self];
        [self.contactListService addDelegate:self];
        
        [self cacheSetup];
    }
    
    return self;
}

#pragma mark - Cache setup

- (void)cacheSetup {
    
    [QMChatCache setupDBWithStoreNamed:kQMChatCacheStoreName];
    [QMContactListCache setupDBWithStoreNamed:kQMContactListCacheStoreName];
}

#pragma mark - QMServiceDataDelegate

- (QBUUser *)serviceDataCurrentProfile {
    
    return self.profile.userData;
}

#pragma mark - QMChatServiceDelegate

- (void)chatServiceDidDialogsHistoryUpdated {
    
}

- (void)chatServiceDidMessagesHistoryUpdated {
    
}

- (void)chatServiceDidAddMessageToHistory:(QBChatMessage *)message
                                forDialog:(QBChatDialog *)dialog {
    
    [[QMChatCache instance] insertOrUpdateMessage:message
                                     withDialogId:dialog.ID
                                             read:YES
                                       completion:nil];
}

- (void)chatServiceDidReceiveNotificationMessage:(QBChatMessage *)message
                                    createDialog:(QBChatDialog *)dialog {
    
    [[QMChatCache instance] insertOrUpdateMessage:message
                                     withDialogId:dialog.ID
                                             read:YES
                                       completion:nil];
    
    [[QMChatCache instance] insertOrUpdateDialog:dialog
                                      completion:nil];
}

- (void)chatServiceDidReceiveNotificationMessage:(QBChatMessage *)message
                                    updateDialog:(QBChatDialog *)dialog {
    
    [[QMChatCache instance] insertOrUpdateMessage:message
                                     withDialogId:dialog.ID
                                             read:YES
                                       completion:nil];
    
    [[QMChatCache instance] insertOrUpdateDialog:dialog
                                      completion:nil];
}

#pragma mark - QMContactsServiceDelegate

- (void)contactsServiceContactListDidUpdate {
    
}

- (void)contactsServiceContactRequestUsersListChanged {
    
}

- (void)contactsServiceUsersHistoryUpdated {
    
}

@end

