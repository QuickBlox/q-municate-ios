//
//  QMUserInfoViewController.h
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 3/23/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMTableViewController.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  User info table view controller.
 */
@interface QMUserInfoViewController : QMTableViewController

/**
 *  User to show info for. Must have a valid user ID.
 */
@property (strong, nonatomic) QBUUser *user;

@end

NS_ASSUME_NONNULL_END
