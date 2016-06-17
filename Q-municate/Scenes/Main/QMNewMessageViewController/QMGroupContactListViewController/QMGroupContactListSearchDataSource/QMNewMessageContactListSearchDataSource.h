//
//  QMNewMessageContactListSearchDataSource.h
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 3/20/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMContactsSearchDataSource.h"
#import "QMSearchProtocols.h"

/**
 *  Group contact list data source class is a child of QMNewMessageDataSource.
 *
 *  @see QMAlphabetizedDataSource class for more information.
 */
@interface QMNewMessageContactListSearchDataSource : QMContactsSearchDataSource

/**
 *  Set of selected users (readonly).
 */
@property (strong, nonatomic, readonly) NSMutableSet <QBUUser *> *selectedUsers;

/**
 *  Determines whether user at index path is selected or not.
 *
 *  @param indexPath index path
 *
 *  @return boolean value of user being selected
 */
- (BOOL)isSelectedUserAtIndexPath:(NSIndexPath *)indexPath;

/**
 *  Set selected state for user at index path.
 *
 *  @param selected  whether user should be selected or not
 *  @param indexPath index path
 */
- (void)setSelected:(BOOL)selected userAtIndexPath:(NSIndexPath *)indexPath;

/**
 *  Deselect specific user even if cell is not visible.
 *
 *  @param user QBUUser instance of user to be deselected
 */
- (void)deselectUser:(QBUUser *)user;

@end
