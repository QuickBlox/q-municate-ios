//
//  QMSiriCache.m
//  Q-municate
//
//  Created by Vitaliy Gurkovsky on 12/1/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMSiriCache.h"

static NSString *const kQMContactListCacheNameKey = @"q-municate-contacts";
static NSString *const kQMChatCacheNameKey = @"sample-cache";
static NSString *const kQMUsersCacheNameKey = @"qb-users-cache";

@implementation QMSiriCache


- (instancetype)initWithApplicationGroupIdentifier:(NSString *)appGroupIdentifier {
    
    self = [super init];
    
    if (self) {
        
        [QMChatCache setupDBWithStoreNamed:kQMChatCacheNameKey applicationGroupIdentifier:appGroupIdentifier];
        [QMUsersCache setupDBWithStoreNamed:kQMUsersCacheNameKey applicationGroupIdentifier:appGroupIdentifier];
        
        // Contact list service init
        [QMContactListCache setupDBWithStoreNamed:kQMContactListCacheNameKey applicationGroupIdentifier:appGroupIdentifier];
        
    }
    return self;
}


//MARK: - Public Methods

- (void)allGroupDialogsWithCompletionBlock:(void (^)(NSArray<QBChatDialog *> *)) completion {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.dialogType == %@ AND SELF.name.length > 0", @(QBChatDialogTypeGroup)];
    
    [QMChatCache.instance dialogsSortedBy:@"name" ascending:YES withPredicate:predicate completion:^(NSArray<QBChatDialog *> * _Nullable dialogs) {

        if (completion) {
            completion(dialogs);
        }
    }];
}

- (void)allContactUsersWithCompletionBlock:(void(^)(NSArray<QBUUser *> *results,NSError *error))completion {
    
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
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.id IN %@",userIDs];
        
        [[[QMUsersCache instance] usersWithPredicate:predicate sortedBy:@"fullName" ascending:YES] continueWithBlock:^id _Nullable(BFTask<NSArray<QBUUser *> *> * _Nonnull t) {
            if (t.faulted) {
                completion(@[],t.error);
            }
            else {
                completion(t.result,nil);
            }
            return  nil;
        }];
        
  
    });
}

- (void)dialogIDForUserWithID:(NSInteger)userID completionBlock:(void(^)(NSString *dialogID))completion {
    
    [QMChatCache.instance allDialogsWithCompletion:^(NSArray <QBChatDialog *> * _Nullable dialogs) {
        
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


//MARK: - Helpers
- (void)createPrivateChatWithOpponentID:(NSUInteger)opponentID completionBlock:(void(^)(QBChatDialog *createdDialog))completion {
    
    QBChatDialog *chatDialog = [[QBChatDialog alloc] initWithDialogID:nil type:QBChatDialogTypePrivate];
    chatDialog.occupantIDs = @[@(opponentID)];
    
    [QBRequest createDialog:chatDialog successBlock:^(QBResponse *response, QBChatDialog *createdDialog) {
        
        if (completion) {
            completion(createdDialog);
        }
        
    } errorBlock:^(QBResponse *response) {
        
        if (completion) {
            completion(nil);
        }
    }];
}

@end
