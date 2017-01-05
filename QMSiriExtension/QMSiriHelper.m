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
#import "QMSiriServiceManager.h"
#import "QBUUser+INPerson.h"
#import "QMINPersonProtocol.h"

static const NSUInteger kQMApplicationID = 36125;
static NSString * const kQMAuthorizationKey = @"gOGVNO4L9cBwkPE";
static NSString * const kQMAuthorizationSecret = @"JdqsMHCjHVYkVxV";
static NSString * const kQMAccountKey = @"6Qyiz3pZfNsex1Enqnp7";
static NSString * const kQMAppGroupIdentifier = @"group.com.quickblox.qmunicate";

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
        // Quickblox settings
        [QBSettings setApplicationID:kQMApplicationID];
        [QBSettings setAuthKey:kQMAuthorizationKey];
        [QBSettings setAuthSecret:kQMAuthorizationSecret];
        [QBSettings setAccountKey:kQMAccountKey];
        [QBSettings setLogLevel:QBLogLevelNothing];
        [QBSettings setApplicationGroupIdentifier:kQMAppGroupIdentifier];
    }
    
    return self;
}

- (QBUUser *)currentUser {
    return [QBSession currentSession].currentUser;
}

//MARK: Matching contacts

- (void)personsMatchingName:(NSString *)displayName completionBlock:(void (^)(NSArray<INPerson*> *matchingContacts))completion {
    
    dispatch_group_t group = dispatch_group_create();
    
    __block NSArray *contactUsers = nil;
    __block NSArray *dialogs = nil;
    
    dispatch_group_enter(group);
    [[QMSiriServiceManager instance] allContactUsersWithCompletionBlock:^(NSArray *results, NSError *error) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            NSPredicate *usersSearchPredicate = [NSPredicate predicateWithFormat:@"SELF.fullName CONTAINS[cd] %@", displayName];
            NSArray *filteredUsers = [results filteredArrayUsingPredicate:usersSearchPredicate];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                contactUsers = filteredUsers;
                dispatch_group_leave(group);
            });
        });
    }];
    
    
    dispatch_group_enter(group);
    [[QMSiriServiceManager instance] allGroupDialogsWithCompletionBlock:^(NSArray<QBChatDialog *> *results) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            NSPredicate *usersSearchPredicate = [NSPredicate predicateWithFormat:@"SELF.name CONTAINS[cd] %@", displayName];
            NSArray *filteredGroupDialogs = [results filteredArrayUsingPredicate:usersSearchPredicate];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                dialogs = filteredGroupDialogs;
                dispatch_group_leave(group);
            });
        });
    }];
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        if (completion) {
            NSArray *allData = [contactUsers arrayByAddingObjectsFromArray:dialogs];
            completion([self personsArrayFromArray:allData]);
        }
    });
}

//MARK: Dialog retrieving

- (void)dialogIDForUserWithID:(NSInteger)userID completionBlock:(void(^)(NSString *dialogID))completion {
    
    [[QMSiriServiceManager instance] dialogIDForUserWithID:userID completionBlock:completion];
}

//MARK: Helpers

- (NSArray *)personsArrayFromArray:(NSArray <id<QMINPersonProtocol>> *)array {
    
    NSMutableArray<INPerson*> *personsArray = [NSMutableArray arrayWithCapacity:array.count];
    
    for (id object in array) {
        if ([object conformsToProtocol:@protocol(QMINPersonProtocol)]) {
            INPerson *person = [object qm_inPerson];
            if (person) {
                [personsArray addObject:person];
            }
        }
    }
    
    return personsArray;
}

NSInteger sort(id a, id b, void *p) {
    return [[a valueForKey:(__bridge NSString*)p]
            compare:[b valueForKey:(__bridge NSString*)p]
            options:NSNumericSearch];
}

@end
