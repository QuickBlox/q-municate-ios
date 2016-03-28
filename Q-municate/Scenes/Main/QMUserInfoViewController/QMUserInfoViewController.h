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
 *  Init.
 *
 *  @warning Unavailable. Use 'chatViewControllerWithChatDialog:' instead.
 *
 *  @return QMUserInfoViewController new instance.
 */
- (nullable instancetype)init NS_UNAVAILABLE;

/**
 *  Init with coder.
 *
 *  @param aDecoder a decoder
 *
 *  @warning Unavailable. Use 'chatViewControllerWithChatDialog:' instead.
 *
 *  @return QMUserInfoViewController new instance.
 */
- (nullable instancetype)initWithCoder:(nonnull NSCoder *)aDecoder NS_UNAVAILABLE;

/**
 *  Init with nib name and bundle.
 *
 *  @param nibNameOrNil   nib name
 *  @param nibBundleOrNil nib bundle
 *
 *  @warning Unavailable. Use 'chatViewControllerWithChatDialog:' instead.
 *
 *  @return QMUserInfoViewController new instance.
 */
- (nonnull instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil NS_UNAVAILABLE;

/**
 *  User info view controller instance with user.
 *
 *  @param user user to instantinate view controller with.
 *
 *  @return QMUserInfoViewController instantiated instance.
 */
+ (nullable instancetype)userInfoViewControllerWithUser:(nonnull QBUUser *)user;

@end
