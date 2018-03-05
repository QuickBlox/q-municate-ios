//
//  QMSiriHelper.h
//  Q-municate
//
//  Created by Vitaliy Gurkovsky on 11/23/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import <QMServices/QMServices.h>

@class INPerson;

@interface QMSiriHelper : NSObject

@property (strong, nonatomic, readonly) QBUUser *currentUser;

+ (instancetype)instance;

- (void)dialogIDForUserWithID:(NSInteger)userID completionBlock:(void(^)(NSString *dialogID))completion;

- (void)personsMatchingName:(NSString *)displayName completionBlock:(void (^)(NSArray<INPerson*> *matchingContacts))completion;

@end
