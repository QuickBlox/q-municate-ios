//
//  QMCore.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 1/8/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMCore.h"
#import <Reachability.h>
#import "QMProfile.h"
#import "QMFacebook.h"
#import <DigitsKit/DigitsKit.h>

NSString *const kQMLastActivityDateKey = @"last_activity_date";

@interface QMCore ()

@property (strong, nonatomic) NSUserDefaults *defaults;

@end

@implementation QMCore

+ (instancetype)instance {
    
    static QMCore *core = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        core = [[self alloc] init];
    });
    
    return core;
}

- (instancetype)init {
    self = [super init];
    
    if (self) {
        // Contact list service init
        [QMContactListCache setupDBWithStoreNamed:kContactListCacheNameKey];
        _contactListService = [[QMContactListService alloc] initWithServiceManager:self cacheDataSource:self];
        [_contactListService addDelegate:self];
        
        // Profile init
        _currentProfile = [QMProfile currentProfile];
        
        // Users cache init
        [self.usersService loadFromCache];
        
        // Reachability init
//        _internetConnection = [Reachability reachabilityForInternetConnection];
        
        _defaults = [NSUserDefaults standardUserDefaults];
    }
    
    return self;
}

#pragma mark - Auth methods

- (BFTask *)logout {
    
    BFTaskCompletionSource* source = [BFTaskCompletionSource taskCompletionSource];
    
    @weakify(self);
    [super logoutWithCompletion:^{
        @strongify(self);
        
        if (self.currentProfile.accountType == QMAccountTypeFacebook) {
            
            [QMFacebook logout];
        } else if (self.currentProfile.accountType == QMAccountTypeDigits) {
            
            [[Digits sharedInstance] logOut];
        }
        
        [self.currentProfile clearProfile];
        
        [source setResult:nil];
    }];
    
    return source.task;
}

#pragma mark - Notifications

- (BFTask *)leaveChatDialog:(QBChatDialog *)chatDialog {
    
    @weakify(self);
    return [[self.chatService sendNotificationMessageAboutLeavingDialog:chatDialog withNotificationText:kDialogsUpdateNotificationMessage] continueWithBlock:^id _Nullable(BFTask * _Nonnull task) {
        
        if (!task.isFaulted) {
            @strongify(self);
            return [self.chatService deleteDialogWithID:chatDialog.ID];
        }
        
        return nil;
    }];
}

#pragma mark - Users

- (NSArray *)friends {
    
    NSArray *ids = [self.contactListService.contactListMemoryStorage userIDsFromContactList];
    NSArray *allFriends = [self.usersService.usersMemoryStorage usersWithIDs:ids];
    
    return allFriends;
}

- (NSArray *)friendsSortedByFullName {
    
    NSSortDescriptor *sorter = [[NSSortDescriptor alloc]
                                initWithKey:@"fullName"
                                ascending:YES
                                selector:@selector(localizedCaseInsensitiveCompare:)];
    NSArray *sortedUsers = [[self friends] sortedArrayUsingDescriptors:@[sorter]];
    
    return sortedUsers;
}

- (NSArray *)idsOfContactsOnly {
    
    NSMutableSet *IDs = [NSMutableSet new];
    NSArray *contactItems = [QBChat instance].contactList.contacts;
    
    for (QBContactListItem *item in contactItems) {
        [IDs addObject:@(item.userID)];
    }
    
    // hardfix for broken contact list until fixed
    for (QBContactListItem *item in [QBChat instance].contactList.pendingApproval) {
        
        if (item.subscriptionState == QBPresenceSubscriptionStateFrom) {
            [IDs addObject:@(item.userID)];
        }
    }
    //
    
    return IDs.allObjects;
}

- (BOOL)isFriendWithUser:(QBUUser *)user {
    
    NSArray *ids = [self.contactListService.contactListMemoryStorage userIDsFromContactList];
    return [ids containsObject:@(user.ID)];
}

- (NSArray *)idsOfUsers:(NSArray *)users {
    
    NSMutableArray *ids = [NSMutableArray array];
    
    for (QBUUser *user in users) {
        
        [ids addObject:@(user.ID)];
    }
    
    return ids.copy;
}

#pragma mark - Last activity date

- (void)setLastActivityDate:(NSDate *)lastActivityDate
{
    [self.defaults setObject:lastActivityDate forKey:kQMLastActivityDateKey];
    [self.defaults synchronize];
}

- (NSDate *)lastActivityDate
{
    return [self.defaults objectForKey:kQMLastActivityDateKey];
}

#pragma mark QMContactListServiceCacheDelegate delegate

- (void)cachedContactListItems:(QMCacheCollection)block {
    
    [[QMContactListCache instance] contactListItems:block];
}

#pragma mark - QMContactListServiceDelegate

- (void)contactListService:(QMContactListService *)contactListService contactListDidChange:(QBContactList *)contactList {
    
    [[QMContactListCache instance] insertOrUpdateContactListItemsWithContactList:contactList completion:nil];
}

@end
