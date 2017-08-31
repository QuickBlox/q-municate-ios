//
//  QMExpandableTableViewController.h
//  Q-municate
//
//  Created by Vitaliy Gurkovsky on 8/29/17.
//  Copyright © 2017 Quickblox. All rights reserved.
//

#import "QMTableViewController.h"

@interface QMExpandableTableViewController : QMTableViewController

- (BOOL)isExpandedCell:(NSIndexPath *)indexPath;

- (void)expandCellForIndexPath:(NSIndexPath *)indexPath
                      duration:(CGFloat)duration
              withRowAnimation:(UITableViewRowAnimation)animation;

- (void)expandCellForIndexPath:(NSIndexPath *)indexPath
              withRowAnimation:(UITableViewRowAnimation)animation;

- (void)reloadExpandedCellForIndexPath:(NSIndexPath *)indexPath
                              duration:(CGFloat)duration
                      withRowAnimation:(UITableViewRowAnimation)animation;

- (void)hideCellForIndexPath:(NSIndexPath *)indexPath
            withRowAnimation:(UITableViewRowAnimation)animation;

- (NSInteger)numberOfExpandedRowsForSection:(NSInteger)section;

@end
