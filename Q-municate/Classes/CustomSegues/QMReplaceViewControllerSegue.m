//
//  QMReplaceViewControllerSegue.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 3/17/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMReplaceViewControllerSegue.h"

@implementation QMReplaceViewControllerSegue

-(void)perform {
    
    UIViewController *sourceViewController = (UIViewController*)[self sourceViewController];
    UIViewController *destinationController = (UIViewController*)[self destinationViewController];
    UINavigationController *navigationController = sourceViewController.navigationController;
    [navigationController pushViewController:destinationController animated:YES];
    
    // remove source view controller from  navigation stack
    NSMutableArray *mutableVC = navigationController.viewControllers.mutableCopy;
    [mutableVC removeObject:sourceViewController];
    navigationController.viewControllers = mutableVC.copy;
}

@end
