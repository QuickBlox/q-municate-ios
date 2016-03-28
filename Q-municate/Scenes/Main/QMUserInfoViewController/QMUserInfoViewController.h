//
//  QMUserInfoViewController.h
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 3/23/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  User info table view controller.
 */
@interface QMUserInfoViewController : UITableViewController

/**
 *  User to show info for. Must have a valid user ID.
 */
@property (strong, nonatomic) QBUUser *user;

- (nullable instancetype)init NS_UNAVAILABLE;
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil NS_UNAVAILABLE;
- (instancetype)initWithStyle:(UITableViewStyle)style NS_UNAVAILABLE;

/**
 *  User info view controller instance with user.
 *
 *  @param user user to instantinate view controller with.
 *
 *  @return QMUserInfoViewController instantiated instance.
 */
+ (nullable instancetype)userInfoViewControllerWithUser:(QBUUser *)user;

@end

NS_ASSUME_NONNULL_END
