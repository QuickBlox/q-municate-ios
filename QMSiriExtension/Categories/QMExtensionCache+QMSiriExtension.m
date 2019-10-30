//
//  QMExtensionCache+QMSiriExtension.m
//  QMSiriExtension
//
//  Created by Injoit on 10/12/17.
//  Copyright © 2017 QuickBlox. All rights reserved.
//

#import "QMExtensionCache+QMSiriExtension.h"

@implementation QMExtensionCache (QMSiriExtension)

+ (void)allDialogsWithCompletionBlock:(void(^)(NSArray<QBChatDialog *> *results))completion {
    [self.chatCache allDialogsWithCompletion:completion];
}

+ (void)allGroupDialogsWithCompletionBlock:(void (^)(NSArray<QBChatDialog *> *results)) completion {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.dialogType == %@ AND SELF.name.length > 0", @(QBChatDialogTypeGroup)];
    [self.chatCache dialogsSortedBy:@"name" ascending:YES withPredicate:predicate completion:^(NSArray<QBChatDialog *> * _Nullable dialogs) {
        
        if (completion) {
            completion(dialogs);
        }
    }];
}

+ (void)allContactUsersWithCompletionBlock:(void(^)(NSArray<QBUUser *> *results,NSError *error))completion {
    
    NSMutableArray *userIDs = [NSMutableArray array];
    dispatch_group_t group = dispatch_group_create();
    
    dispatch_group_enter(group);
    [self.contactsCache contactListItems:^(NSArray<QBContactListItem *> * _Nonnull contactListItems) {
        
        for (QBContactListItem *item in contactListItems) {
            if (item.subscriptionState != QBPresenceSubscriptionStateNone) {
                [userIDs addObject:@(item.userID)];
            }
        }
        dispatch_group_leave(group);
    }];
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.id IN %@",userIDs];
        
        [[self.usersCache usersWithPredicate:predicate sortedBy:@"fullName" ascending:YES] continueWithBlock:^id _Nullable(BFTask<NSArray<QBUUser *> *> * _Nonnull t) {
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

+ (void)dialogIDForUserWithID:(NSInteger)userID
              completionBlock:(void(^)(NSString *dialogID))completion {
    
    [self.chatCache allDialogsWithCompletion:^(NSArray <QBChatDialog *> * _Nullable dialogs) {
        
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
+ (void)createPrivateChatWithOpponentID:(NSUInteger)opponentID
                        completionBlock:(void(^)(QBChatDialog *createdDialog))completion {
    
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
