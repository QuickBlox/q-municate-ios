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

@class QMSearchResultsController;

@protocol QMSearchResultsControllerDelegate <NSObject>

- (void)searchResultsController:(QMSearchResultsController *)searchResultsController willBeginScrollResults:(UIScrollView *)scrollView;
- (void)searchResultsController:(QMSearchResultsController *)searchResultsController didPushViewController:(UIViewController *)viewController;

@end

@interface QMSearchResultsController : UITableViewController

<
QMSearchProtocol,
QMSearchDataProviderDelegate
>

@property (weak, nonatomic) id <QMSearchResultsControllerDelegate>delegate;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithNavigationController:(UINavigationController *)navigationController;

- (void)performSearch:(NSString *)searchText;

@end
