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



- (void)groupDialogWithName:(NSString *)dialogName completionBlock:(void (^)(QBChatDialog *dialog))completion {
    [[QMSiriServiceManager instance] groupDialogWithName:dialogName completionBlock:completion];
}

//MARK: Matching contacts
- (void)contactsMatchingName:(NSString *)displayName completionBlock:(void (^)(NSArray<INPerson*> *matchingContacts))completion {
    
    [[QMSiriServiceManager instance] allContactsWithCompletionBlock:^(NSArray *results, NSError *error) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{

            NSPredicate *usersSearchPredicate = [NSPredicate predicateWithFormat:@"SELF.fullName CONTAINS[cd] %@", displayName];
            NSArray *contacts = [results filteredArrayUsingPredicate:usersSearchPredicate];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) {
                    completion([self personsArrayFromUsersArray:contacts.copy]);
                }
            });
        });
    }];
}

//MARK: Dialog retrieving

- (void)dialogIDForUserWithID:(NSInteger)userID completionBlock:(void(^)(NSString *dialogID))completion {
    
    [[QMSiriServiceManager instance] dialogIDForUserWithID:userID completionBlock:completion];
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



@end
