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

@interface QMServicesManager()

<QMServiceDataDelegate, QMChatServiceDelegate, QMContactListServiceDelegate, QMContactListServiceCacheDelegate, QMChatServiceCacheDelegate >

@property (strong, nonatomic) QMAuthService *authService;
@property (strong, nonatomic) QMChatService *chatService;
@property (strong, nonatomic) QMContactListService *contactListService;
@property (strong, nonatomic) QMProfile *profile;

@end

@implementation QMServicesManager

+ (instancetype)instance {
    
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

- (instancetype)init {
    
    self = [super init];
    
    if (self) {
        
        self.profile = [QMProfile profile];
        
        [self cacheSetup];
        
        self.authService =
        [[QMAuthService alloc] initWithServiceDataDelegate:self];
        
        self.chatService =
        [[QMChatService alloc] initWithServiceDataDelegate:self
                                             cacheDelegate:self];
        
        self.contactListService =
        [[QMContactListService alloc] initWithServiceDataDelegate:self
                                                    cacheDelegate:self];
        
        [self.chatService addDelegate:self];
        [self.contactListService addDelegate:self];
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

- (void)chatService:(QMChatService *)chatService didAddChatDialogs:(NSArray *)chatDialogs {
    [[QMChatCache instance] insertOrUpdateDialogs:chatDialogs
                                       completion:nil];
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

#pragma mark - QMChatServiceCacheDelegate

- (void)cachedDialogs:(QMCacheCollection)block {
    
    [[QMChatCache instance] dialogsSortedBy:@"lastMessageDate"
                                  ascending:NO
                                 completion:block];
}

- (void)cachedMessagesWithDialogID:(NSString *)dialogID block:(QMCacheCollection)block {
    
}

#pragma mark - QMContactListServiceCacheDelegate

- (void)cachedUsers:(QMCacheCollection)block {
    
    [[QMContactListCache instance] usersSortedBy:nil
                                       ascending:NO
                                      completion:block];
}

- (void)cachedContactListItems:(QMCacheCollection)block {
    
    [[QMContactListCache instance] contactListItems:block];
}

#pragma mark - QMContactListServiceDelegate

- (void)contactListService:(QMContactListService *)contactListService
      contactListDidChange:(QBContactList *)contactList {
    
    [[QMContactListCache instance] insertOrUpdateContactListItemsWithContactList:contactList
                                                                      completion:nil];
}

- (void)contactListService:(QMContactListService *)contactListService
        addRequestFromUser:(QBUUser *)user {
    
}

- (void)contactListService:(QMContactListService *)contactListService
                didAddUser:(QBUUser *)user {
    
    [[QMContactListCache instance] insertOrUpdateUser:user
                                           completion:nil];
}

- (void)contactListService:(QMContactListService *)contactListService
               didAddUsers:(NSArray *)users {
    
    [[QMContactListCache instance] insertOrUpdateUsers:users
                                            completion:nil];
}

- (void)contactListService:(QMContactListService *)contactListService
             didUpdateUser:(QBUUser *)user {
    
}

@end