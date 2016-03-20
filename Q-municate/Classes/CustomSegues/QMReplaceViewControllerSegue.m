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
    
    // Grab Variables for readability
    UIViewController *sourceViewController = (UIViewController*)[self sourceViewController];
    UIViewController *destinationController = (UIViewController*)[self destinationViewController];
    UINavigationController *navigationController = sourceViewController.navigationController;
    
    if (navigationController.viewControllers != nil) {
        
        // Get a changeable copy of the stack
        NSMutableArray *controllerStack = navigationController.viewControllers.mutableCopy;
        
        // Replace the source controller with the destination controller, wherever the source may be
        [controllerStack replaceObjectAtIndex:[controllerStack indexOfObject:sourceViewController] withObject:destinationController];
        
        // Assign the updated stack with animation
        [navigationController setViewControllers:controllerStack animated:YES];
    }
}

@end
