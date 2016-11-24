//
//  QMSiriHelper.h
//  Q-municate
//
//  Created by Vitaliy Gurkovsky on 11/23/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import <QMServices.h>


@interface QMSiriHelper : QMServicesManager <
QMContactListServiceCacheDataSource,
QMContactListServiceDelegate
>
/**
 *  Contact list service.
 */
@property (strong, nonatomic, readonly) QMContactListService *contactListService;

- (void)contactsMatchingName:(NSString *)displayName withCompletionBlock:(void (^)(NSArray *matchingContacts))completion;

- (NSArray *)personsArrayFromUsersArray:(NSArray *)usersArray;

- (void)dialogIDForUserWithID:(NSInteger)userID withCompletion:(void(^)(NSString *dialogID))completion;

- (void)createPrivateChatWithOpponentID:(NSUInteger)opponentID completion:(void(^)( QBChatDialog *createdDialog))completion;

@end
