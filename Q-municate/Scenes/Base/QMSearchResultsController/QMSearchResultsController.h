//
//  QMSearchResultsController.h
//  Q-municate
//
//  Created by Injoit on 5/17/16.
//  Copyright © 2016 QuickBlox. All rights reserved.
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

- (void)searchResultsController:(QMSearchResultsController *)searchResultsController willBeginScrollResults:(UIScrollView *)scrollView;

- (void)searchResultsController:(QMSearchResultsController *)searchResultsController didSelectObject:(id)object;

@end


@interface QMSearchResultsController : UITableViewController

<
QMSearchProtocol,
QMSearchDataProviderDelegate
>

@property (weak, nonatomic, nullable) id<QMSearchResultsControllerDelegate> delegate;


/**
 *  Perform search.
 *
 *  @param searchText search text
 */
- (void)performSearch:(nullable NSString *)searchText;

@end

NS_ASSUME_NONNULL_END
