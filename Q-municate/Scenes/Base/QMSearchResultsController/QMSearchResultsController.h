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

@interface QMSearchResultsController : UITableViewController

<
QMSearchProtocol,
QMSearchDataProviderDelegate
>

- (void)performSearch:(NSString *)searchText;

@end
