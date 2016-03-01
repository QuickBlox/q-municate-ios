//
//  QMSearchResultsController.h
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 2/29/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QMSearchResultsController : UITableViewController

- (void)localSearch:(NSString *)searchText;

- (void)globalSearch:(NSString *)searchText;

@end
