//
//  QMSiriHelper.h
//  Q-municate
//
//  Created by Injoit on 11/23/16.
//  Copyright © 2016 QuickBlox. All rights reserved.
//

#import <Quickblox/Quickblox.h>

@class INPerson;

@interface QMSiriHelper : NSObject

@property (strong, nonatomic, readonly) QBUUser *currentUser;

+ (instancetype)instance;

- (void)dialogIDForUserWithID:(NSInteger)userID completionBlock:(void(^)(NSString *dialogID))completion;

- (void)personsMatchingName:(NSString *)displayName completionBlock:(void (^)(NSArray<INPerson*> *matchingContacts))completion;

@end
