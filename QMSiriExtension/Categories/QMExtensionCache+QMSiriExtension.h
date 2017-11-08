//
//  QMExtensionCache+QMSiriExtension.h
//  QMSiriExtension
//
//  Created by Vitaliy Gurkovsky on 10/12/17.
//  Copyright © 2017 Quickblox. All rights reserved.
//

#import "QMExtensionCache.h"

@interface QMExtensionCache (QMSiriExtension)

+ (void)allDialogsWithCompletionBlock:(void(^)(NSArray<QBChatDialog *> *results))completion;
+ (void)allGroupDialogsWithCompletionBlock:(void (^)(NSArray<QBChatDialog *> *results)) completion;
+ (void)allContactUsersWithCompletionBlock:(void(^)(NSArray<QBUUser *> *results,NSError *error))completion;

+ (void)dialogIDForUserWithID:(NSInteger)userID
              completionBlock:(void(^)(NSString *dialogID))completion;

@end
