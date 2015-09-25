//
//  QMContactListService+CustomMethods.h
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 9/25/15.
//  Copyright © 2015 Quickblox. All rights reserved.
//

#import <QMContactListService.h>

typedef void (^QBUUserPagedResponseBlock)(QBResponse *response, QBGeneralResponsePage *page, NSArray *users);
typedef void (^QBResponseBlock)(QBResponse *response);

@interface QMContactListService(CustomMethods)

/**
 *  IDs of contact in current chat instance.
 */
- (NSArray *)idsOfContactsOnly;

- (void)retrieveUsersWithFacebookIDs:(NSArray *)facebookIDs completion:(QBUUserPagedResponseBlock)completion;

- (void)retrieveUsersWithEmails:(NSArray *)emails completion:(QBUUserPagedResponseBlock)completion;

- (void)resetUserPasswordWithEmail:(NSString *)email completion:(QBResponseBlock)completion;

- (QBRequest *)retrieveUsersWithFullName:(NSString *)searchText pagedRequest:(QBGeneralResponsePage *)page completion:(QBUUserPagedResponseBlock)completion;

@end
