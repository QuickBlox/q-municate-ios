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
#import "QMExtensionCache+QMSiriExtension.h"
#import "QBUUser+INPerson.h"
#import "QMINPersonProtocol.h"
#import "QBSettings+Qmunicate.h"

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
       [QBSettings configure];
    }
    
    return self;
}

- (QBUUser *)currentUser {
    return [QBSession currentSession].currentUser;
}

//MARK:- Matching contacts

- (void)personsMatchingName:(NSString *)displayName completionBlock:(void (^)(NSArray<INPerson*> *matchingContacts))completion {
    
    dispatch_group_t group = dispatch_group_create();
    
    __block NSArray *contactUsers = @[];
    __block NSArray *dialogs = @[];
    
    dispatch_group_enter(group);
    [QMExtensionCache allContactUsersWithCompletionBlock:^(NSArray *results, NSError *error) {
        
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
    [QMExtensionCache allGroupDialogsWithCompletionBlock:^(NSArray<QBChatDialog *> *results) {
        
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

//MARK:- Dialog retrieving

- (void)dialogIDForUserWithID:(NSInteger)userID completionBlock:(void(^)(NSString *dialogID))completion {
    
    [QMExtensionCache dialogIDForUserWithID:userID completionBlock:completion];
}

//MARK:- Helpers

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

@end
