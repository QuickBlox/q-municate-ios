//
//  QMSiriServiceManager.m
//  Q-municate
//
//  Created by Vitaliy Gurkovsky on 12/1/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMSiriServiceManager.h"

@implementation QMSiriServiceManager

static NSString *const kQMContactListCacheNameKey = @"q-municate-contacts";

- (instancetype)init {
    
    self = [super init];
    
    if (self) {
        // Contact list service init
        [QMContactListCache setupDBWithStoreNamed:kQMContactListCacheNameKey applicationGroupIdentifier:[self appGroupIdentifier]];
        _contactListService = [[QMContactListService alloc] initWithServiceManager:self cacheDataSource:self];
        [_contactListService addDelegate:self];
    }
    return self;
}

//MARK: - Public Methods

- (void)groupDialogWithName:(NSString *)name completionBlock:(void(^)(QBChatDialog *dialog))completion {
    
    [[QMChatCache instance] allDialogsWithCompletion:^(NSArray <QBChatDialog *> * _Nullable dialogs) {
        
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(QBChatDialog*  _Nullable dialog, NSDictionary<NSString *,id> * _Nullable bindings) {
            return dialog.type == QBChatDialogTypeGroup && [dialog.name caseInsensitiveCompare:name] == NSOrderedSame;
        }];
        
        QBChatDialog *dialog = [[dialogs filteredArrayUsingPredicate:predicate] firstObject];
        
        if (completion) {
            completion(dialog);
        }
    }];
}

- (void)allContactsWithCompletionBlock:(void(^)(NSArray *results, NSError *error))completion {
    
    NSMutableArray *userIDs = [NSMutableArray array];
    dispatch_group_t group = dispatch_group_create();
    
    dispatch_group_enter(group);
    [[QMContactListCache instance] contactListItems:^(NSArray<QBContactListItem *> * _Nonnull contactListItems) {
        
        for (QBContactListItem *item in contactListItems) {
            if (item.subscriptionState != QBPresenceSubscriptionStateNone) {
                [userIDs addObject:@(item.userID)];
            }
        }
        dispatch_group_leave(group);
    }];
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        
        [[self.usersService getUsersWithIDs:userIDs forceLoad:YES] continueWithBlock:^id _Nullable(BFTask<NSArray<QBUUser *> *> * _Nonnull t) {
            if (t.faulted) {
                completion(nil,t.error);
            }
            else {
                completion(t.result,nil);
            }
            return nil;
        }];
    });
}

- (void)dialogIDForUserWithID:(NSInteger)userID completionBlock:(void(^)(NSString *dialogID))completion {
    
    [[QMChatCache instance] allDialogsWithCompletion:^(NSArray <QBChatDialog *> * _Nullable dialogs) {
        
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(QBChatDialog*  _Nullable dialog, NSDictionary<NSString *,id> * _Nullable bindings) {
            return dialog.type == QBChatDialogTypePrivate && [dialog.occupantIDs containsObject:@(userID)];
        }];
        
        QBChatDialog *dialog = [[dialogs filteredArrayUsingPredicate:predicate] firstObject];
        
        if (dialog != nil) {
            
            if (completion) {
                completion(dialog.ID);
            }
        }
        else {
            [self createPrivateChatWithOpponentID:userID completionBlock:^(QBChatDialog *createdDialog) {
                if (completion) {
                    completion(createdDialog.ID);
                }
            }];
        }
    }];
}

//MARK: - QMContactListServiceCacheDelegate delegate

- (void)cachedContactListItems:(QMCacheCollection)block {
    
    [[QMContactListCache instance] contactListItems:block];
}

//MARK: - QMContactListServiceDelegate

- (void)contactListService:(QMContactListService *)__unused contactListService contactListDidChange:(QBContactList *)contactList {
    
    [[QMContactListCache instance] insertOrUpdateContactListItemsWithContactList:contactList completion:nil];
    
    // load users if needed
    [self.usersService getUsersWithIDs:[self.contactListService.contactListMemoryStorage userIDsFromContactList]];
}

//MARK: - QMServiceManagerProtocol
- (NSString *)appGroupIdentifier {
    return @"group.com.quickblox.qmunicate";
}

//MARK: - Helpers
- (void)createPrivateChatWithOpponentID:(NSUInteger)opponentID completionBlock:(void(^)(QBChatDialog *createdDialog))completion {
    [self.chatService createPrivateChatDialogWithOpponentID:opponentID completion:^(QBResponse * _Nonnull response, QBChatDialog * _Nullable createdDialog) {
        if (completion) {
            completion(createdDialog);
        }
    }];
}

@end
