//
//  QMTableViewController.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 6/19/17.
//  Copyright © 2017 Quickblox. All rights reserved.
//

#import "QMTableViewController.h"

#import "QMNavigationController.h"

@implementation QMTableViewController

// MARK: - Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Hide empty separators
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    if (self.splitViewController.isCollapsed && [self.navigationController isKindOfClass:[QMNavigationController class]]) {
        QMNavigationController *navController = (QMNavigationController *)self.navigationController;
        if (navController.currentAdditionalNavigationBarHeight > 0) {
            self.additionalNavigationBarHeight = navController.currentAdditionalNavigationBarHeight;
        }
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(navigationBarHeightChanged)
                                                 name:kQMNavigationBarHeightChangeNotification
                                               object:nil];
}

// MARK: - Overrides

- (void)setAdditionalNavigationBarHeight:(CGFloat)additionalNavigationBarHeight {
    CGFloat previousAdditionalNavigationBarHeight = _additionalNavigationBarHeight;
    _additionalNavigationBarHeight = additionalNavigationBarHeight;
    
    if (self.isViewLoaded) {
        
        CGPoint contentOffset = self.tableView.contentOffset;
        UIEdgeInsets finalInset = self.tableView.contentInset;
        UIEdgeInsets finalScrollIndicatorInsets = self.tableView.scrollIndicatorInsets;
        UIEdgeInsets previousInset = self.tableView.contentInset;
        
        finalInset.top += additionalNavigationBarHeight - previousAdditionalNavigationBarHeight;
        finalScrollIndicatorInsets.top += additionalNavigationBarHeight - previousAdditionalNavigationBarHeight;
        
        self.tableView.contentInset = finalInset;
        self.tableView.scrollIndicatorInsets = finalScrollIndicatorInsets;
        
        if (UIEdgeInsetsEqualToEdgeInsets(previousInset, UIEdgeInsetsZero)) {
            contentOffset.y -= finalInset.top;
            [self.tableView setContentOffset:contentOffset animated:NO];
        }
    }
}

// MARK: - Notification

- (void)navigationBarHeightChanged {
    self.additionalNavigationBarHeight = [(QMNavigationController *)self.navigationController currentAdditionalNavigationBarHeight];
}

@end
