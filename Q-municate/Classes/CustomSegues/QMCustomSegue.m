//
//  QMCustomSegue.m
//  Q-municate
//
//  Created by Igor Alefirenko on 13/02/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMCustomSegue.h"
#import "QMWelcomeScreenViewController.h"
#import "QMSignUpController.h"
#import "QMLogInController.h"


@implementation QMCustomSegue

- (void)perform {
    
    QMWelcomeScreenViewController *sourceController = self.sourceViewController;
    UINavigationController *nextController = self.destinationViewController;
    
    if ([sourceController.childViewControllers count] > 0) {
        UIView *lastView = sourceController.lastView;
        UINavigationController *lastController = sourceController.lastController;
        if ([sourceController.childViewControllers containsObject:lastController]) {
            [lastController removeFromParentViewController];
        }
        if ([sourceController.view.subviews containsObject:lastView]) {
            [lastView removeFromSuperview];
        }
    }
    [sourceController addChildViewController:nextController];
    sourceController.lastController = nextController;
    
    [sourceController.view addSubview:nextController.view];
    sourceController.lastView = nextController.view;
    
    // take root controller from navigation controller:
    id contentViewController = [nextController.viewControllers lastObject];
    // check class of content controller:
    if ([contentViewController isKindOfClass:[QMSignUpController class]]) {
        ((QMSignUpController *)contentViewController).root = sourceController;
    } else if ([contentViewController isKindOfClass:[QMLogInController class]]){
        ((QMLogInController *)contentViewController).root = sourceController;
    }
}

@end
