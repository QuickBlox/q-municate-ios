//
//  QMChatService+CustomMethods.h
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 9/24/15.
//  Copyright © 2015 Quickblox. All rights reserved.
//

#import <QMChatService.h>

typedef void (^QBDialogsPagedResponseBlock)(QBResponse *response, NSArray *dialogObjects, NSSet *dialogsUsersIDs, QBResponsePage *page);
typedef void (^QBChatDialogResponseBlock)(QBResponse *response, QBChatDialog *updatedDialog);

@interface QMChatService (CustomMethods)

/**
 *  Fetching dialog with last activity from date
 *
 *  @param date date  from last activity
 *  @param completion completion block with response
 */
- (void)fetchDialogsWithLastActivityFromDate:(NSDate *)date completion:(QBDialogsPagedResponseBlock)completionBlock;

/**
 *  Update dialog
 *
 *  @param dialog     dialog to update
 *  @param completion completion block with response
 */
- (void)updateChatDialog:(QBChatDialog *)dialog completion:(QBChatDialogResponseBlock)completion;

@end
