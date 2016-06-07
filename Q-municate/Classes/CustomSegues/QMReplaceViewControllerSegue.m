//
//  QMReplaceViewControllerSegue.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 3/17/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMReplaceViewControllerSegue.h"

@implementation QMReplaceViewControllerSegue

- (void)perform {
    
    // Grab Variables for readability
    UIViewController *sourceViewController = self.sourceViewController;
    UIViewController *destinationController = self.destinationViewController;
    UINavigationController *navigationController = sourceViewController.navigationController;
    
    if (navigationController.viewControllers != nil) {
        
        // Get a changeable copy of the stack
        NSMutableArray *controllerStack = [navigationController.viewControllers mutableCopy];
        
        // Replace the source controller with the destination controller, wherever the source may be
        NSUInteger index = [controllerStack indexOfObject:sourceViewController];
        controllerStack[index] = destinationController;
        
        // Assign the updated stack with animation
        [navigationController setViewControllers:[controllerStack copy] animated:YES];
    }
}

@end
