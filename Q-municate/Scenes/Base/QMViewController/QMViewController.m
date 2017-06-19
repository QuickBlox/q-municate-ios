//
//  QMViewController.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 6/19/17.
//  Copyright © 2017 Quickblox. All rights reserved.
//

#import "QMViewController.h"

#import "QMNavigationController.h"

@implementation QMViewController

// MARK: - Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
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

// MARK: - Notification

- (void)navigationBarHeightChanged {
    self.additionalNavigationBarHeight = [(QMNavigationController *)self.navigationController currentAdditionalNavigationBarHeight];
}

@end
