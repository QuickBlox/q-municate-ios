//
//  QMSiriHelper.h
//  Q-municate
//
//  Created by Vitaliy Gurkovsky on 11/23/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import <QMServices.h>

@class INPerson;

@interface QMSiriHelper : NSObject

@property (strong, nonatomic, readonly) QBUUser *currentUser;

+ (instancetype)instance;

- (void)dialogIDForUserWithID:(NSInteger)userID completionBlock:(void(^)(NSString *dialogID))completion;
- (void)groupDialogWithName:(NSString *)dialogName completionBlock:(void (^)(QBChatDialog *dialog))completion;
- (void)contactsMatchingName:(NSString *)displayName completionBlock:(void (^)(NSArray<INPerson*> *matchingContacts))completion;

@end
