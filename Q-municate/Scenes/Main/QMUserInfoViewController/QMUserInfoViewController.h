//
//  QMUserInfoViewController.h
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 3/23/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  User info table view controller.
 */
@interface QMUserInfoViewController : UITableViewController

/**
 *  User to show info for. Must have a valid user ID.
 */
@property (strong, nonatomic, nonnull) QBUUser *user;

/**
 *  User info view controller instance with user.
 *
 *  @param user user to instantinate view controller with.
 *
 *  @return QMUserInfoViewController instantiated instance.
 */
+ (nullable instancetype)userInfoViewControllerWithUser:(nonnull QBUUser *)user;

@end
