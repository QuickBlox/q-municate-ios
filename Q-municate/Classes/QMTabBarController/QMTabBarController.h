//
//  QMTabBarController.h
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 5/5/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  QMTabBarController class interface.
 *  Custom tab bar controller, based on UIViewController.
 *  Designed to let all view controllers, that are existent in tab bar,
 *  to have one and only navigation controller.
 */
@interface QMTabBarController : UIViewController

/**
 *  Tab bar.
 *
 *  @discussion Use it to configure tab bar appearance.
 *
 *  @warning Do not override items property or you will receive an unexpected behaviour
 *  for view controllers management. Use 'addBarItemWithTitle:image:viewController:' for it instead.
 */
@property (strong, nonatomic, readonly) UITabBar *tabBar;

/**
 *  Array of current view controllers.
 */
@property (nullable, strong, nonatomic, readonly) NSArray *viewControllers;

/**
 *  Current displayed view controller.
 */
@property (nullable, strong, nonatomic, readonly) UIViewController *selectedViewController;

/**
 *  Add bar item with title, image and conforming view controller.
 *
 *  @param title          title of bar item
 *  @param image          image of bar item
 *  @param viewController view controller that conforms to bar item
 */
- (void)addBarItemWithTitle:(nullable NSString *)title image:(nullable UIImage *)image viewController:(UIViewController *)viewController;

/**
 *  Remove bar item and release view controller that conforms to it.
 *
 *  @param itemIndex item index
 */
- (void)removeItemAtIndex:(NSUInteger)itemIndex;

@end

NS_ASSUME_NONNULL_END
