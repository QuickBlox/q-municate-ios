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

- (QBUUser*)currentUser {
    return [QBSession currentSession].currentUser;
}

//MARK: Matching contacts

- (void)contactsMatchingName:(NSString *)displayName withCompletionBlock:(void (^)(NSArray<INPerson*> *matchingContacts))completion {
    
    [[QMSiriServiceManager instance] getAllUsersNamesWithCompletion:^(NSArray *results, NSError *error) {
        
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
    
    [[QMSiriServiceManager instance] dialogIDForUserWithID:userID withCompletion:completion];
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
