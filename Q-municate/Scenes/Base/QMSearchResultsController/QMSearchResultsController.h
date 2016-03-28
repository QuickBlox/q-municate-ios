//
//  QMSearchResultsController.h
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 2/29/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QMSearchProtocols.h"
#import "QMSearchDataProvider.h"

NS_ASSUME_NONNULL_BEGIN

@class QMSearchResultsController;

/**
 *  QMSearchResultsControllerDelegate protocol. Used to notify about search result controller actions.
 */
@protocol QMSearchResultsControllerDelegate <NSObject>

/**
 *  Protocol methods down below are required to be implemented
 */
@required

/**
 *  Notifying about search result controller begin scrolling through search results.
 *
 *  @param searchResultsController QMSearchResultsController instance.
 *  @param scrollView              scroll view instance
 */
- (void)searchResultsController:(QMSearchResultsController *)searchResultsController willBeginScrollResults:(UIScrollView *)scrollView;

/**
 *  Notifying about search result controller pushed new view controller
 *
 *  @param searchResultsController QMSearchResultsController instance.
 *  @param viewController          view controller that was pushed
 */
- (void)searchResultsController:(QMSearchResultsController *)searchResultsController didPushViewController:(UIViewController *)viewController;

@end

/**
 *  Search result controller to display results with.
 */
@interface QMSearchResultsController : UITableViewController

<
QMSearchProtocol,
QMSearchDataProviderDelegate
>

@property (weak, nonatomic, nullable) id <QMSearchResultsControllerDelegate>delegate;

/**
 *  Init.
 *
 *  @warning Unavailable. Use 'initWithNavigationController:' instead.
 *
 *  @return QMSearchResultsController new instance.
 */
- (nullable instancetype)init NS_UNAVAILABLE;

/**
 *  Init with coder.
 *
 *  @param aDecoder a decoder
 *
 *  @warning Unavailable. Use 'initWithNavigationController:' instead.
 *
 *  @return QMSearchResultsController new instance.
 */
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;

/**
 *  Init with nib name and bundle.
 *
 *  @param nibNameOrNil   nib name
 *  @param nibBundleOrNil nib bundle
 *
 *  @warning Unavailable. Use 'initWithNavigationController:' instead.
 *
 *  @return QMSearchResultsController new instance.
 */
- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil NS_UNAVAILABLE;

/**
 *  Init with style.
 *
 *  @param style UITableViewStyle
 *
 *  @warning Unavailable. Use 'initWithNavigationController:' instead.
 *
 *  @return QMSearchResultsController new instance.
 */
- (instancetype)initWithStyle:(UITableViewStyle)style NS_UNAVAILABLE;

/**
 *  Init with navigation controller.
 *
 *  @param navigationController navigation controller
 *
 *  @return QMSearchResultsController new instance.
 */
- (nullable instancetype)initWithNavigationController:(UINavigationController *)navigationController;

/**
 *  Perform search.
 *
 *  @param searchText search text
 */
- (void)performSearch:(nullable NSString *)searchText;

@end

NS_ASSUME_NONNULL_END
