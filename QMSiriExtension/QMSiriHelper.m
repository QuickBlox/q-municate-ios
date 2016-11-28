//
//  QMSiriHelper.m
//  Q-municate
//
//  Created by Vitaliy Gurkovsky on 11/23/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMSiriHelper.h"
#import <Quickblox/Quickblox.h>
#import <Intents/Intents.h>

static NSString *const kQMContactListCacheNameKey = @"q-municate-contacts";

@implementation QMSiriHelper

//MARK: - Initialization
+ (instancetype)instance {
    
    static QMSiriHelper *siriHelperInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        siriHelperInstance = [[self alloc] init];
    });
    
    return siriHelperInstance;
}

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

//MARK: Matching contacts


- (void)contactsMatchingName:(NSString *)displayName withCompletionBlock:(void (^)(NSArray<INPerson*> *matchingContacts))completion {
    
    [self getAllUsersNamesWithCompletion:^(NSArray *results, NSError *error) {
        
        NSMutableArray *contacts = [NSMutableArray arrayWithCapacity:results.count];
        
        for (QBUUser *user in results) {
            if ([user.fullName containsString:displayName]) {
                [contacts addObject:user];
            }
        }
        if (completion) {
            completion([self personsArrayFromUsersArray:contacts.copy]);
        }
    }];
}

//MARK: Dialog retrieving

- (void)dialogIDForUserWithID:(NSInteger)userID withCompletion:(void(^)(NSString *dialogID))completion {
    
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
            [self createPrivateChatWithOpponentID:userID completion:^(QBChatDialog *createdDialog) {
                if (completion) {
                    completion(createdDialog.ID);
                }
            }];
        }
    }];
}

//MARK: - QMServiceManagerProtocol
- (NSString *)appGroupIdentifier {
    return @"group.com.quickblox.qmunicate";
}

//MARK: - Helpers

- (void)getAllUsersNamesWithCompletion:(void(^)(NSArray* results,NSError * error))completion {
    
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
        
        [[self.usersService getUsersWithIDs:userIDs] continueWithBlock:^id _Nullable(BFTask<NSArray<QBUUser *> *> * _Nonnull t) {
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

- (NSArray *)personsArrayFromUsersArray:(NSArray *)usersArray {
    
    NSMutableArray<INPerson*> *personsArray = [NSMutableArray arrayWithCapacity:usersArray.count];
    
    for (QBUUser *user in usersArray) {
        INPersonHandle *handle = [[INPersonHandle alloc] initWithValue:user.login type:INPersonHandleTypeUnknown];
        INPerson *person = [[INPerson alloc] initWithPersonHandle:handle
                                                   nameComponents:nil
                                                      displayName:user.fullName
                                                            image:nil
                                                contactIdentifier:[NSString stringWithFormat:@"%lu",(unsigned long)user.ID]
                                                 customIdentifier:nil];
        [personsArray addObject:person];
    }
    
    return personsArray;
}

- (void)createPrivateChatWithOpponentID:(NSUInteger)opponentID completion:(void(^)( QBChatDialog *createdDialog))completion {
    [self.chatService createPrivateChatDialogWithOpponentID:opponentID completion:^(QBResponse * _Nonnull response, QBChatDialog * _Nullable createdDialog) {
        if (completion) {
            completion(createdDialog);
        }
    }];
}

@end
