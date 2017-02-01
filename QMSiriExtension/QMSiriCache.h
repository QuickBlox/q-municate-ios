//
//  QMSiriCache.h
//  Q-municate
//
//  Created by Vitaliy Gurkovsky on 12/1/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import <QMServices.h>

@interface QMSiriCache : NSObject

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithApplicationGroupIdentifier:(NSString *)appGroupIdentifier;

- (void)allGroupDialogsWithCompletionBlock:(void (^)(NSArray<QBChatDialog *> *results)) completion;
- (void)allContactUsersWithCompletionBlock:(void(^)(NSArray<QBUUser *> *results,NSError *error))completion;

- (void)dialogIDForUserWithID:(NSInteger)userID completionBlock:(void(^)(NSString *dialogID))completion;

@end
