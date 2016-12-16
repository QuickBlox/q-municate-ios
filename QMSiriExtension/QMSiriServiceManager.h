//
//  QMSiriServiceManager.h
//  Q-municate
//
//  Created by Vitaliy Gurkovsky on 12/1/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import <QMServices.h>

@interface QMSiriServiceManager : QMServicesManager <
QMContactListServiceCacheDataSource,
QMContactListServiceDelegate
>

@property (strong, nonatomic, readonly) QMContactListService *contactListService;

- (void)allContactsWithCompletionBlock:(void(^)(NSArray *results,NSError *error))completion;
- (void)dialogIDForUserWithID:(NSInteger)userID completionBlock:(void(^)(NSString *dialogID))completion;
- (void)groupDialogWithName:(NSString *)name completionBlock:(void(^)(QBChatDialog *dialog))completion;

@end
