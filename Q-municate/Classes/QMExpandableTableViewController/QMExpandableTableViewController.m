//
//  QMExpandableTableViewController.m
//  Q-municate
//
//  Created by Vitaliy Gurkovsky on 8/29/17.
//  Copyright © 2017 Quickblox. All rights reserved.
//

#import "QMExpandableTableViewController.h"
#import "QMTimeOut.h"

@interface QMExpandableTableViewController () {
    QMTimeOut *_dismissTimeOut;
}

@property (nonatomic, strong) NSMutableSet *expandedCells;
@end

@implementation QMExpandableTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _expandedCells = [NSMutableSet set];
}
- (void)expandCellForIndexPath:(NSIndexPath *)indexPath
              withRowAnimation:(UITableViewRowAnimation)animation {
    
    [self expandCellForIndexPath:indexPath
                        duration:0
                withRowAnimation:animation];
}

- (void)expandCellForIndexPath:(NSIndexPath *)indexPath
                      duration:(CGFloat)duration
              withRowAnimation:(UITableViewRowAnimation)animation {
    
    NSIndexPath *expandedCellIndexPath = expandedIndexPath(indexPath);
    
    if (![self.expandedCells containsObject:expandedCellIndexPath]) {
        
        if (_dismissTimeOut) {
            [_dismissTimeOut cancelTimeout];
        }
        
        if (duration > 0) {
            
            _dismissTimeOut = [[QMTimeOut alloc] initWithTimeInterval:duration
                                                                queue:dispatch_get_main_queue()];
            __weak typeof(self) weakSelf = self;
            [_dismissTimeOut startWithFireBlock:^{
                [weakSelf hideCellForIndexPath:indexPath withRowAnimation:animation];
            }];
        }
        
        [self.expandedCells addObject:expandedCellIndexPath];
        
        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:@[expandedCellIndexPath]
                              withRowAnimation:animation];
        [self.tableView endUpdates];
    }
}

- (void)reloadExpandedCellForIndexPath:(NSIndexPath *)indexPath
                              duration:(CGFloat)duration
                      withRowAnimation:(UITableViewRowAnimation)animation {
    
    NSIndexPath *expandedCellIndexPath = expandedIndexPath(indexPath);
    
    if ([self.expandedCells containsObject:expandedCellIndexPath]) {
        
        if (_dismissTimeOut) {
            [_dismissTimeOut cancelTimeout];
        }
        
        if (duration > 0) {
            
            _dismissTimeOut = [[QMTimeOut alloc] initWithTimeInterval:duration
                                                                queue:dispatch_get_main_queue()];
            __weak typeof(self) weakSelf = self;
            [_dismissTimeOut startWithFireBlock:^{
                [weakSelf hideCellForIndexPath:indexPath withRowAnimation:UITableViewRowAnimationAutomatic];
            }];
        }
        
        [self.tableView beginUpdates];
        
        [self.tableView reloadRowsAtIndexPaths:@[expandedCellIndexPath]
                              withRowAnimation:animation];
        [self.tableView endUpdates];
    }
    
}

- (void)hideCellForIndexPath:(NSIndexPath *)indexPath
            withRowAnimation:(UITableViewRowAnimation)animation {
    
    NSIndexPath *expandedCellIndexPath = expandedIndexPath(indexPath);
    
    if ([self.expandedCells containsObject:expandedCellIndexPath]) {
        
        if (_dismissTimeOut) {
            [_dismissTimeOut cancelTimeout];
        }
        [self.tableView beginUpdates];
        [self.expandedCells removeObject:expandedCellIndexPath];
        [self.tableView deleteRowsAtIndexPaths:@[expandedCellIndexPath]
                              withRowAnimation:animation];
        [self.tableView endUpdates];
    }
}

- (BOOL)isExpandedCell:(NSIndexPath *)indexPath {
    return [self.expandedCells containsObject:indexPath];
}

- (NSInteger)numberOfExpandedRowsForSection:(NSInteger)section {
    
    NSInteger numberOfExpandedRows = 0;
    for (NSIndexPath *indexPath in [self.expandedCells copy]) {
        if (indexPath.section == section) {
            numberOfExpandedRows++;
        }
    }
    
    return numberOfExpandedRows;
}

- (NSInteger)tableView:(UITableView *)__unused tableView
indentationLevelForRowAtIndexPath:(NSIndexPath *)__unused indexPath {
    return 0;
}

static inline NSIndexPath* expandedIndexPath(NSIndexPath *indexPath) {
    NSInteger expandedCellRow = indexPath.row + 1;
    return [NSIndexPath indexPathForRow:expandedCellRow
                              inSection:indexPath.section];
}

@end
